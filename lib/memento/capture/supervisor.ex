defmodule Memento.Capture.Supervisor do
  use Supervisor

  alias Memento.Capture.Twitter

  def start_link(env) do
    Supervisor.start_link(__MODULE__, env, name: __MODULE__)
  end

  def init(env) do
    Supervisor.init(children(env), strategy: :one_for_one)
  end

  defp children(:test), do: []

  defp children(_env) do
    twitter_feed_start_args =
      {
        System.get_env("TWITTER_CONSUMER_KEY"),
        System.get_env("TWITTER_CONSUMER_SECRET"),
        Twitter.Feed
      }

    [{Twitter.Feed, twitter_feed_start_args}]
  end
end
