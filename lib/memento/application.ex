defmodule Memento.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Memento.Repo,
      # Start the Telemetry supervisor
      MementoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Memento.PubSub},
      # Start the Endpoint (http/https)
      MementoWeb.Endpoint,
      # Start capture infra
      Memento.Capture.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Memento.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    MementoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
