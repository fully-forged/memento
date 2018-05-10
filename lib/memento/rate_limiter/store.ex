defmodule Memento.RateLimiter.Store do
  @moduledoc """
  A in-memory data store with support for time-based deletion.

  Entries are stored as `{key, insertion_time, counter}`.
  """

  alias Memento.RateLimiter

  @doc """
  Creates a table. The name has to be unique.
  """
  def create_table(name) do
    opts = [
      :set,
      :public,
      :named_table,
      {:write_concurrency, true},
      {:read_concurrency, true}
    ]

    :ets.new(name, opts)
  end

  @doc """
  Creates a test table, available only on the local node.
  """
  def create_test_table(name) do
    opts = [
      :set,
      {:write_concurrency, true},
      {:read_concurrency, true}
    ]

    :ets.new(name, opts)
  end

  @doc """
  Increments the counter for a given key (defaulting to 0 if it doesn't exist).

  The operation is atomic.
  """
  def inc(table_name, key) do
    # The following update operation reads as: update the counter at position 3
    # by incrementing it by 1. If the counter exceeds the value of
    # `max_per_interval`, resets it to `max_per_interval` (this means that we won't
    # store bigger integers for nothing).
    update_op =
      {3, 1, RateLimiter.max_per_interval(), RateLimiter.max_per_interval()}

    :ets.update_counter(table_name, key, update_op, {key, now(), 0})
  end

  @doc """
  Returns the current counter value for a given key.
  """
  def get(table_name, key) do
    case :ets.lookup(table_name, key) do
      [{^key, _timestamp, count}] -> count
      _missing -> 0
    end
  end

  @doc """
  Deletes all keys older than the specified timestamp.

  Note that the operation IS NOT atomic, as we need to fetch all entries first
  and then delete them.
  """
  def delete_older_than(table_name, unix_microsecs) do
    # This reads as:
    #
    # Return true (required by `:ets.select_delete/2` for all object in the
    # table where the second tuple element captured with `$1` is lesser or
    # equal than the constant value `unix_microsecs`.
    spec = {{:_, :"$1", :_}, [{:"=<", :"$1", {:const, unix_microsecs}}], [true]}

    :ets.select_delete(table_name, [spec])
  end

  @doc """
  Returns true if the given key hasn't reached the configured rate limit.
  """
  def can_access?(table_name, key) do
    get(table_name, key) < RateLimiter.max_per_interval()
  end

  @doc """
  Returns a unix epoch suitable for usage with the store entries.
  """
  def now do
    DateTime.utc_now() |> DateTime.to_unix(:microsecond)
  end
end
