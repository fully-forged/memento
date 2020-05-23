defmodule Memento.Capture do
  @moduledoc """
  Allows performing source capture actions outside of the automatic workflow.
  """

  alias Memento.Capture
  alias Phoenix.PubSub

  @doc """
  Refreshes all sources with running feed.
  """
  def refresh_feeds, do: Capture.Supervisor.refresh_feeds()

  @doc """
  Starts a new feed given a handler module.
  """
  def start_feed(handler), do: Capture.Supervisor.start_feed(handler)

  @doc """
  Stops the feed for a given handler module.
  """
  def stop_feed(handler), do: Capture.Supervisor.stop_feed(handler)

  @doc """
  Subscribes the current process to capture events
  """
  def subscribe do
    PubSub.subscribe(Memento.PubSub, "capture")
  end

  @doc """
  Returns all enabled handlers entry types.
  """
  def enabled_entry_types do
    Enum.map(Capture.Supervisor.enabled_handlers(), fn h -> h.entry_type() end)
  end
end
