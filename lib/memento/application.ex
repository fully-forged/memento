defmodule Memento.Application do
  @moduledoc false

  use Application

  alias Memento.API.Router

  def start(_type, env) do
    children = [
      {Memento.Repo, []},
      {Memento.Capture.Supervisor, env},
      Memento.RateLimiter.Supervisor,
      {Plug.Adapters.Cowboy2, scheme: :http, plug: Router, options: [port: 8080]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Memento.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_phase(:create_status_table, _type, _env) do
    Memento.Capture.Status.create_table()
    :ok
  end

  def start_phase(:create_rate_limiter_table, _type, _args) do
    Memento.RateLimiter.create_table()
    :ok
  end
end
