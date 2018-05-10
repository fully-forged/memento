defmodule Memento.RateLimiter do
  alias Memento.RateLimiter.Store

  @doc """
  The maximum amount of calls per interval.
  """
  def max_per_interval, do: get_config(:max_per_interval, 30)

  @doc """
  The duration of the interval. Limits are reset after this expires.
  """
  def reset_interval_in_ms, do: get_config(:reset_interval_in_ms, 5000)

  @doc """
  The interval used to schedule pruning.

  If the reset interval is set to 10 seconds, pruning will happen at most
  at either 9 seconds or 11 seconds.
  """
  def prune_interval_in_ms, do: div(reset_interval_in_ms(), 10)

  @doc """
  Creates the table that holds consumption data.
  """
  def create_table do
    __MODULE__ = Store.create_table(__MODULE__)
  end

  @doc """
  Gets the current counter for the given key.
  """
  def get(key), do: Store.get(__MODULE__, key)

  @doc """
  Increments the counter for the given key.
  """
  def inc(key), do: Store.inc(__MODULE__, key)

  @doc """
  Returns true if the key is under the specified limits.
  """
  def can_access?(key), do: Store.can_access?(__MODULE__, key)

  defp get_config(key, default) do
    Application.get_env(:memento, __MODULE__, [])
    |> Keyword.get(key, default)
  end
end
