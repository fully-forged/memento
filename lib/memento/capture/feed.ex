defmodule Memento.Capture.Feed do
  @behaviour :gen_statem

  alias Memento.{Repo, Schema.Entry}

  require Logger

  def child_spec(config) do
    %{
      id: {__MODULE__, config.handler},
      start: {__MODULE__, :start_link, [config]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def callback_mode, do: :state_functions

  def start_link(config) do
    :gen_statem.start_link({:local, config.name}, __MODULE__, config, [])
  end

  def refresh(worker) do
    :gen_statem.call(worker, :refresh)
  end

  def init(config) do
    action = {:next_event, :internal, :authorize}
    {:ok, :idle, config, action}
  end

  def idle(:internal, :authorize, state) do
    case state.handler.authorize(state.data) do
      {:ok, new_data} ->
        action = {:next_event, :internal, :refresh}
        new_state = %{state | data: new_data}
        {:next_state, :authorized, new_state, action}

      {:error, reason} ->
        Logger.error(fn ->
          """
          Error authorizing #{inspect(state.handler)}.

          Reason: #{inspect(reason)}
          """
        end)

        {:stop, reason}
    end
  end

  def authorized(event_type, :refresh, state)
      when event_type in [:internal, :timeout] do
    case refresh_and_save(state.handler, state.data) do
      {:ok, new_count, new_data} ->
        state.status.track(state.handler)

        Logger.info(fn ->
          """
          Refreshed #{inspect(state.handler)}, added #{new_count} new entries.
          """
        end)

        action = {:timeout, state.refresh_interval, :refresh}
        new_state = %{state | data: new_data}
        {:keep_state, new_state, action}

      {:error, reason} ->
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

  def authorized({:call, from}, :refresh, state) do
    case refresh_and_save(state.handler, state.data) do
      {:ok, new_count, new_data} ->
        state.status.track(state.handler)

        actions = [
          {:reply, from, {:ok, new_count}},
          {:timeout, state.refresh_interval, :refresh}
        ]

        new_state = %{state | data: new_data}

        {:keep_state, new_state, actions}

      {:error, reason} ->
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
    now = DateTime.utc_now()

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
