defmodule Memento.API.RateLimiter do
  import Plug.Conn

  alias Memento.RateLimiter

  def init(opts) do
    opts
    |> Keyword.get(:only, [])
  end

  def call(conn, limited_paths) do
    if conn.request_path in limited_paths do
      rate_limit(conn)
    else
      conn
    end
  end

  defp rate_limit(conn) do
    if RateLimiter.can_access?(conn.request_path) do
      RateLimiter.inc(conn.request_path)
      conn
    else
      conn
      |> send_resp(
        :too_many_requests,
        Jason.encode!(%{error: :rate_limit_reached})
      )
      |> halt()
    end
  end
end
