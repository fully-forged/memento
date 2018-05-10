defmodule Memento.RateLimiter.Prune do
  alias Memento.RateLimiter.Store

  def start_link(table_name, reset_interval_in_ms, prune_interval_in_ms) do
    state = %{
      table_name: table_name,
      reset_interval_in_ms: reset_interval_in_ms,
      prune_interval_in_ms: prune_interval_in_ms
    }

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :prune, state.prune_interval_in_ms)
    {:ok, state}
  end

  def handle_info(:prune, state) do
    threshold_in_microsecs = Store.now() - 1000 * state.reset_interval_in_ms

    Store.delete_older_than(state.table_name, threshold_in_microsecs)

    Process.send_after(self(), :prune, state.prune_interval_in_ms)

    {:noreply, state}
  end
end
