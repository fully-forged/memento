defmodule Memento.Application do
  @moduledoc false

  use Application

  alias Memento.API.Router

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Router, [], port: 8080)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Memento.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
