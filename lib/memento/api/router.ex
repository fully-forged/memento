defmodule Memento.API.Router do
  @moduledoc false

  use Plug.Router
  use Plug.ErrorHandler

  alias Memento.{API.QsParamsValidator, Entry.Query, Repo, Schema.Entry}

  plug Logster.Plugs.Logger

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.Static,
    from: {:memento, "priv/static/#{Mix.env()}"},
    at: "/assets"

  plug :match
  plug :dispatch

  get "/" do
    html_resp(conn, 200, Memento.Template.index())
  end

  get "/status" do
    json_resp(conn, 200, get_status())
  end

  get "/entries/refresh" do
    Memento.Capture.Supervisor.refresh_all()

    json_resp(conn, 200, Poison.encode!(%{status: :refreshed}))
  end

  get "/entries" do
    {:ok, %{page: page, per_page: per_page, type: type, q: q}} =
      QsParamsValidator.validate(conn.query_params)

    limit = per_page
    offset = (page - 1) * per_page

    query = Query.ordered_by_saved_at_desc(Entry, limit, offset)

    with_filters_query =
      case {q, type} do
        {:not_provided, :all} ->
          query

        {q, type} when is_binary(q) ->
          if String.length(q) >= 3 do
            prefix_q = q <> ":*"
            Query.search(query, prefix_q)
          else
            Query.by_type(query, type)
          end

        {_q, type} ->
          Query.by_type(query, type)
      end

    body =
      with_filters_query
      |> Repo.all()
      |> Poison.encode!()

    json_resp(conn, 200, body)
  end

  match _ do
    html_resp(conn, 404, "Not found")
  end

  defp get_status do
    Memento.Capture.Status.all()
    |> Poison.encode!()
  end

  defp html_resp(conn, status_code, body) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_resp(status_code, body)
  end

  defp json_resp(conn, status_code, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status_code, body)
  end
end
