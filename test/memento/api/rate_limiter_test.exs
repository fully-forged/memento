defmodule Auth.Api.V2.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias Memento.API.Router
  @api_router_opts Router.init([])

  describe "rate limits" do
    setup do
      current_config = Application.get_env(:memento, Memento.RateLimiter)

      new_config = Keyword.put(current_config, :max_per_interval, 0)

      Application.put_env(:memento, Memento.RateLimiter, new_config)

      on_exit(fn ->
        Application.put_env(:memento, Memento.RateLimiter, current_config)
      end)
    end

    test "entries/refresh" do
      conn =
        conn(:post, "/entries/refresh", "")
        |> Router.call(@api_router_opts)

      assert conn.status == 429

      assert %{"error" => "rate_limit_reached"} ==
               Poison.decode!(conn.resp_body)
    end
  end
end
