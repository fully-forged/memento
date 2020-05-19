defmodule MementoWeb.EntriesController do
  use MementoWeb, :controller

  alias Memento.Entry
  alias MementoWeb.QsParamsValidator

  def index(conn, params) do
    case QsParamsValidator.validate(params) do
      {:ok, search_params} ->
        entries = Entry.search(search_params)
        json(conn, entries)

      {:error, _reason} ->
        resp(conn, :bad_request, "malformed request")
    end
  end
end
