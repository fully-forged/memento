defmodule Memento.RateLimiter.Supervisor do
  use Supervisor

  alias Memento.RateLimiter

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Memento.RateLimiter.Prune,
       [
         RateLimiter,
         RateLimiter.reset_interval_in_ms(),
         RateLimiter.prune_interval_in_ms()
       ]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
