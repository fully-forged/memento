defmodule Memento.RateLimiter.Supervisor do
  use Supervisor

  alias Memento.RateLimiter

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Memento.RateLimiter.Prune, [
        RateLimiter,
        RateLimiter.reset_interval_in_ms(),
        RateLimiter.prune_interval_in_ms()
      ])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
