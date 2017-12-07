defmodule Memento.API.EntriesResource do
  use PlugRest.Resource

  alias Memento.{API.QsParamsValidator, Repo, Schema.Entry}

  import Ecto.Query

  def allowed_methods(conn, state) do
    {["GET", "OPTIONS"], conn, state}
  end

  def content_types_provided(conn, state) do
    {[{"application/json", :to_json}], conn, state}
  end

  def to_json(conn, state) do
    {:ok, %{page: page, per_page: per_page, type: type}} =
      QsParamsValidator.validate(conn.query_params)

    limit = per_page
    offset = (page - 1) * per_page

    query =
      from e in Entry,
        order_by: [desc: :saved_at],
        limit: ^limit,
        offset: ^offset

    query =
      case type do
        :all ->
          query

        filtered_type ->
          from e in query, where: e.type == ^filtered_type
      end

    body =
      query
      |> Repo.all()
      |> Poison.encode!()

    {body, conn, state}
  end
end
