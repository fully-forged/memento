defmodule Memento.Capture.FeedTest do
  use ExUnit.Case, async: true
  use Memento.DbTestCase

  alias Memento.{Capture, Repo, Schema.Entry}

  defmodule TestHandler do
    @behaviour Capture.Handler

    def initial_data, do: %{}

    def authorize(%{valid: "credentials"}) do
      {:ok, %{passed: :authorization}}
    end

    def authorize(%{invalid: "credentials"}) do
      {:error, %{failed: :authorization}}
    end

    def refresh(data) do
      # not great, but we need to give time to the test below
      # to get ownership of a db connection
      Process.sleep(5)

      twitter_fav = %{
        id: "935532750223880194",
        text: "dialyzex - A Mix task for type-checking your Elixir project with dialyzer https://t.co/CLgZiRapp9",
        screen_name: "oss_elixir",
        urls: ["https://github.com/comcast/dialyzex"],
        created_at: ~N[2017-11-28 15:36:03]
      }

      {
        :ok,
        [twitter_fav],
        Map.update(data, :refresh_counter, 1, fn v -> v + 1 end)
      }
    end

    # need to use a real type as they're locked by the enum definition
    def entry_type, do: :twitter_fav
    def get_saved_at(content), do: content.created_at
  end

  describe "with invalid credentials" do
    @tag :capture_log
    test "it stops the worker", context do
      Process.flag(:trap_exit, true)

      config = %{
        name: context.test,
        handler: TestHandler,
        data: %{invalid: "credentials"},
        refresh_interval: 30000,
        retry_interval: 5000
      }

      {:ok, worker} = Capture.Feed.start_link(config)

      assert_receive {:EXIT, ^worker, %{failed: :authorization}}
      refute Process.alive?(worker)
    end
  end

  describe "with valid credentials" do
    setup context do
      parent = self()

      config = %{
        name: context.test,
        handler: TestHandler,
        data: %{valid: "credentials"},
        refresh_interval: 10,
        retry_interval: 50
      }

      {:ok, worker} = Capture.Feed.start_link(config)

      Ecto.Adapters.SQL.Sandbox.allow(Repo, parent, worker)

      {:ok, worker: worker}
    end

    test "it enters authorized state", %{worker: worker} do
      assert {:authorized, _} = :sys.get_state(worker)
    end

    test "it automatically refreshes data", %{worker: worker} do
      assert {:authorized, %{data: %{refresh_counter: 1}}} =
               :sys.get_state(worker)

      Process.sleep(10)

      assert {:authorized, %{data: %{refresh_counter: 2}}} =
               :sys.get_state(worker)
    end

    test "it refreshes data on demand", %{worker: worker} do
      assert {:ok, 0} == Capture.Feed.refresh(worker)
    end

    test "it saves data", %{worker: worker} do
      assert {:authorized, %{data: %{refresh_counter: 1}}} =
               :sys.get_state(worker)

      assert 1 == Repo.aggregate(Entry, :count, :id)
    end
  end
end
