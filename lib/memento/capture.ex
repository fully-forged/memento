defmodule Memento.Capture do
  @moduledoc """
  Allows performing source capture actions outside of the automatic workflow.
  """

  alias Memento.Capture

  @doc """
  Refreshes all sources with running feed.
  """
  def refresh_all, do: Capture.Supervisor.refresh_all()

  @doc """
  Returns the status of the last refresh attempt.
  """
  def status, do: Capture.Status.all()
end
