defmodule Memento.Capture.Status do
  @moduledoc """
  Tracks last updates per Capture handler.
  """

  def create_table() do
    :ets.new(__MODULE__, [:set, :public, :named_table])
  end

  def track(handler, status) do
    now = DateTime.utc_now()
    :ets.insert(__MODULE__, {handler, now, status})
  end

  def all do
    :ets.tab2list(__MODULE__)
    |> format_as_map()
  end

  defp format_as_map(table_list) do
    Enum.map(table_list, fn {handler, timestamp, status} ->
      %{handler: handler, last_update: timestamp, status: status}
    end)
  end
end
