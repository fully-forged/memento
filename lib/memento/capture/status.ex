defmodule Memento.Capture.Status do
  @moduledoc """
  Tracks last updates per Capture handler.
  """

  alias Phoenix.PubSub

  @type status :: :success | :auth_failure | :refresh_failure
  @type entry :: %{handler: module, last_update: DateTime.t(), status: status}

  @spec create_table :: __MODULE__ | no_return
  def create_table() do
    :ets.new(__MODULE__, [:set, :public, :named_table])
  end

  @spec track(module(), status(), pos_integer()) :: :ok | {:error, term()}
  def track(handler, status, new_count \\ 0) do
    current_time = DateTime.utc_now()
    :ets.insert(__MODULE__, {handler.entry_type(), current_time, status})

    event_params = %{
      type: handler.entry_type(),
      last_update: current_time,
      status: status,
      new_count: new_count
    }

    PubSub.broadcast(Memento.PubSub, "capture", event_params)
  end

  @spec all :: [entry]
  def all do
    :ets.tab2list(__MODULE__)
    |> format_as_map()
  end

  defp format_as_map(table_list) do
    Enum.map(table_list, fn {entry_type, timestamp, status} ->
      %{type: entry_type, last_update: timestamp, status: status}
    end)
  end
end
