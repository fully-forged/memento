defmodule Memento.Capture.Twitter.Feed do
  use GenServer

  alias Memento.Capture.Twitter.Client

  def start_link(consumer_key, consumer_secret, name) do
    GenServer.start_link(__MODULE__, {consumer_key, consumer_secret}, name: name)
  end

  def start_link(consumer_key, consumer_secret) do
    GenServer.start_link(__MODULE__, {consumer_key, consumer_secret})
  end

  def init({consumer_key, consumer_secret}) do
    case Client.get_token(consumer_key, consumer_secret) do
      {:ok, resp} ->
        {:ok, Map.get(resp, "access_token")}

      error ->
        error |> IO.inspect()
        {:stop, :invalid_credentials}
    end
  end
end
