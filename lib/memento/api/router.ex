defmodule Memento.API.Router do
  use PlugRest.Router
  use Plug.ErrorHandler

  plug Logster.Plugs.Logger

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison

  plug Plug.Static,
    from: {:memento, "priv/static/#{Mix.env()}"},
    at: "/assets"

  plug :match
  plug :dispatch

  resource "/entries", Memento.API.EntriesResource

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
