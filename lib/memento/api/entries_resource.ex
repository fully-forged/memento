defmodule Memento.API.EntriesResource do
  use PlugRest.Resource

  alias Memento.{API.Pagination, Repo, Schema.Entry}

  import Ecto.Query

  def allowed_methods(conn, state) do
    {["GET", "OPTIONS"], conn, state}
  end

  def content_types_provided(conn, state) do
    {[{"application/json", :to_json}], conn, state}
  end

  def to_json(conn, state) do
    {limit, offset} = Pagination.parse(conn.query_params)

    query =
      from e in Entry,
        order_by: [desc: :saved_at],
        limit: ^limit,
        offset: ^offset

    body =
      query
      |> Repo.all()
      |> Poison.encode!()

    {body, conn, state}
  end
end
