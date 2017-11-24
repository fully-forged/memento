defmodule Memento.API.Router do
  use PlugRest.Router
  use Plug.ErrorHandler

  plug :match
  plug :dispatch

  resource "/entries", Memento.API.EntriesResource

  match "/match" do
    send_resp(conn, 200, "Match")
  end
end
