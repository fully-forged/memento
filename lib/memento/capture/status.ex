defmodule Memento.Capture.Status do
  @moduledoc """
  Tracks last updates per Capture handler.
  """

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(args), do: {:ok, args}

  def track(handler) do
    now = DateTime.utc_now()
    GenServer.cast(__MODULE__, {:track, handler, now})
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def handle_cast({:track, handler, now}, state) do
    {:noreply, Map.put(state, handler, now)}
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end
end
