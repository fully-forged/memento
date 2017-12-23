defmodule Memento.Capture.Supervisor do
  use Supervisor

  alias Memento.Capture.{Feed, Github, Instapaper, Pinboard, Twitter}

  def start_link(env) do
    Supervisor.start_link(__MODULE__, env, name: __MODULE__)
  end

  def refresh_all do
    Enum.each(workers(), fn w ->
      Feed.refresh(w)
    end)
  end

  def init(env) do
    Supervisor.init(children(env), strategy: :one_for_one)
  end

  defp children(:test), do: []

  defp children(_env) do
    Enum.map(workers(), fn w ->
      {Feed, w}
    end)
  end

  defp workers do
    [Twitter.Handler, Github.Handler, Pinboard.Handler, Instapaper.Handler]
  end
end
