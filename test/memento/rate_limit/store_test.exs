defmodule Memento.RateLimiter.StoreTest do
  use ExUnit.Case, async: true

  alias Memento.RateLimiter.Store

  setup :create_table

  test "it allows by default", %{table_id: table_id} do
    assert 0 == Store.get(table_id, "non-existent-key")
    assert Store.can_access?(table_id, "non-existent-key")
  end

  test "it increments by 1", %{table_id: table_id} do
    assert 1 == Store.inc(table_id, "session-key")
    assert 2 == Store.inc(table_id, "session-key")
    assert 2 == Store.get(table_id, "session-key")
  end

  test "it can prune older entries", %{table_id: table_id} do
    1 = Store.inc(table_id, "first-key")

    now = Store.now()

    1 = Store.inc(table_id, "second-key")

    1 = Store.delete_older_than(table_id, now)

    assert 0 == Store.get(table_id, "first-key")
    assert 1 == Store.get(table_id, "second-key")
  end

  test "increment, reach limit and reset", %{table_id: table_id} do
    times = Memento.RateLimiter.max_per_interval()

    Enum.each(1..times, fn _ -> Store.inc(table_id, "session-key") end)

    refute Store.can_access?(table_id, "session-key")

    now = Store.now()

    1 = Store.delete_older_than(table_id, now)

    assert Store.can_access?(table_id, "session-key")
  end

  defp create_table(config) do
    # test descriptions have to be unique and they're
    # cast to atoms, so we can use them as table names
    table_name = config.test

    table_id = Store.create_test_table(table_name)

    [table_id: table_id]
  end
end
