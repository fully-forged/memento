defmodule Memento.Capture.Supervisor do
  use Supervisor

  alias Memento.Capture.{Feed, Github, Instapaper, Pinboard, Twitter}

  def start_link(env) do
    Supervisor.start_link(__MODULE__, env, name: __MODULE__)
  end

  def init(env) do
    Supervisor.init(children(env), strategy: :one_for_one)
  end

  defp children(:test), do: []

  defp children(_env) do
    [
      {Feed, Twitter.Handler},
      {Feed, Github.Handler},
      {Feed, Pinboard.Handler},
      {Feed, Instapaper.Handler}
    ]
  end
end
