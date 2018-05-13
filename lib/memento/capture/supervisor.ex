defmodule Memento.Capture.Supervisor do
  @moduledoc false
  use Supervisor

  alias Memento.Capture.{Feed, Status}

  @refresh_interval Application.get_env(:memento, :refresh_interval, 60_000 * 5)
  @retry_interval Application.get_env(:memento, :retry_interval, 30_000)
  @enabled_handlers Application.get_env(:memento, :enabled_handlers, [])

  def start_link(env) do
    Supervisor.start_link(__MODULE__, env, name: __MODULE__)
  end

  def refresh_feeds do
    __MODULE__
    |> Supervisor.which_children()
    |> Enum.map(fn child -> :erlang.element(2, child) end)
    |> Enum.filter(&is_pid/1)
    |> do_refresh_all()
  end

  def start_feed(handler) do
    Supervisor.start_child(__MODULE__, {Feed, worker_config(handler)})
  end

  def init(_env) do
    children =
      Enum.map(@enabled_handlers, fn w ->
        {Feed, worker_config(w)}
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp worker_config(handler) do
    %{
      handler: handler,
      name: handler,
      data: handler.initial_data(),
      status: Status,
      refresh_interval: @refresh_interval,
      retry_interval: @retry_interval
    }
  end

  defp do_refresh_all(workers) do
    workers
    |> Enum.map(fn w ->
      Task.async(Feed, :refresh, [w])
    end)
    |> Enum.map(&Task.await/1)
  end
end
