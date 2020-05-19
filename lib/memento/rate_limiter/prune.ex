defmodule Memento.RateLimiter.Prune do
  use GenServer
  alias Memento.RateLimiter.Store

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl true
  def init(config) do
    Process.send_after(self(), :prune, config.prune_interval_in_ms)
    {:ok, config}
  end

  @impl true
  def handle_info(:prune, config) do
    threshold_in_microsecs = Store.now() - 1000 * config.reset_interval_in_ms

    Store.delete_older_than(config.table_name, threshold_in_microsecs)

    Process.send_after(self(), :prune, config.prune_interval_in_ms)

    {:noreply, config}
  end
end
