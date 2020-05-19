defmodule Memento.Capture.Feed do
  @moduledoc """
  The `Memento.Capture.Feed` module implements a state machine capable
  of periodically fetching and saving new data from a specific source,
  optionally with authentication.

  A `Memento.Capture.Feed` instance is started with a configuration map (see `t:config/0`
  for more details about its structure.

  The details of how to connect and authenticate with the external source
  are captured in the `Memento.Capture.Handler` behaviour.

  In case of authentication failure, the worker will terminate.

  A `Memento.Capture.Feed` state machine can be inserted in a supervision tree with:

      children = [
        {Memento.Capture.Feed, config}
      ]

  For more details about supervision, see `child_spec/1`.
  """
  @behaviour :gen_statem

  alias Memento.{Capture.Handler, Repo, Schema.Entry}

  require Logger

  @typedoc """
  The configuration for a `Memento.Capture.Feed` worker is a map with the
  following properties:

  - **handler**: the name of a module which implements the `Memento.Capture.Handler` behaviour.
  - **name**: a process name for the state machine process. This will also be used by default as id for the worker
    inside a supervision tree.
  - **data**: the starting data necessary for the worker to function. More often than not its value
    is the handler's return value of `c:Memento.Capture.Handler.initial_data/0`.
  - **status**: a module which can be used to track the status of this worker (most likely `Memento.Capture.Status`).
  - **refresh_interval**: the interval, in milliseconds, between data refreshes.
  - **retry_interval**: the interval, in milliseconds, between subsequent attempts to refresh the data in case of failure.
  """
  @type config :: %{
          handler: module(),
          name: atom(),
          data: Handler.data(),
          status: module(),
          refresh_interval: pos_integer(),
          retry_interval: pos_integer()
        }

  @doc """
  Given the starting config for the state machine, it returns a valid
  child specification. Note that by default this implementation assumes one single worker
  per handler per supervision tree (as the handler name is used as id for the child).
  """
  @spec child_spec(config) :: Supervisor.child_spec()
  def child_spec(config) do
    %{
      id: {__MODULE__, config.handler},
      start: {__MODULE__, :start_link, [config]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc false
  def callback_mode, do: :state_functions

  @doc """
  Starts a new state machine with the specified configuration.
  """
  @spec start_link(config) :: :gen_statem.start_ret()
  def start_link(config) do
    :gen_statem.start_link({:local, config.name}, __MODULE__, config, [])
  end

  @doc """
  Forces a refresh for the specified state machine.

  Returns either `{:ok, new_entries_count}` or `{:error, reason}`.
  """
  @spec refresh(pid() | atom()) :: {:ok, non_neg_integer} | {:error, term}
  def refresh(worker) do
    :gen_statem.call(worker, :refresh)
  end

  @doc false
  def init(config) do
    action = {:next_event, :internal, :authorize}
    {:ok, :idle, config, action}
  end

  @doc false
  def idle(:internal, :authorize, state) do
    case state.handler.authorize(state.data) do
      {:ok, new_data} ->
        action = {:next_event, :internal, :refresh}
        new_state = %{state | data: new_data}
        {:next_state, :authorized, new_state, action}

      {:error, reason} ->
        state.status.track(state.handler, :auth_failure)

        Logger.error(fn ->
          """
          Error authorizing #{inspect(state.handler)}.

          Reason: #{inspect(reason)}
          """
        end)

        {:stop, reason}
    end
  end

  @doc false
  def authorized(event_type, :refresh, state)
      when event_type in [:internal, :timeout] do
    case refresh_and_save(state.handler, state.data) do
      {:ok, new_count, new_data} ->
        state.status.track(state.handler, :success)

        Logger.info(fn ->
          """
          Refreshed #{inspect(state.handler)}, added #{new_count} new entries.
          """
        end)

        action = {:timeout, state.refresh_interval, :refresh}
        new_state = %{state | data: new_data}
        {:keep_state, new_state, action}

      {:error, reason} ->
        state.status.track(state.handler, :refresh_failure)

        Logger.error(fn ->
          """
          Error refreshing #{inspect(state.handler)}.

          Reason: #{inspect(reason)}
          """
        end)

        action = {:timeout, state.retry_interval, :refresh}
        {:keep_state_and_data, action}
    end
  end

  @doc false
  def authorized({:call, from}, :refresh, state) do
    case refresh_and_save(state.handler, state.data) do
      {:ok, new_count, new_data} ->
        state.status.track(state.handler, :success)

        actions = [
          {:reply, from, {:ok, new_count}},
          {:timeout, state.refresh_interval, :refresh}
        ]

        new_state = %{state | data: new_data}

        {:keep_state, new_state, actions}

      {:error, reason} ->
        state.status.track(state.handler, :refresh_failure)

        actions = [
          {:reply, from, {:error, reason}},
          {:timeout, state.refresh_interval, :refresh}
        ]

        {:keep_state_and_data, actions}
    end
  end

  defp refresh_and_save(handler, data) do
    case handler.refresh(data) do
      {:ok, new_entries_data, new_data} ->
        {new_count, _} = insert_all(new_entries_data, handler)
        {:ok, new_count, new_data}

      error ->
        error
    end
  end

  defp insert_all(new_entries_data, handler) do
    now =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    inserts =
      Enum.map(new_entries_data, fn new_entry_data ->
        [
          type: handler.entry_type(),
          content: new_entry_data,
          saved_at: handler.get_saved_at(new_entry_data),
          inserted_at: now,
          updated_at: now
        ]
      end)

    Repo.insert_all(Entry, inserts, on_conflict: :nothing)
  end
end
