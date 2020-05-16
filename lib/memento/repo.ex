defmodule Memento.Repo do
  @moduledoc false

  use Ecto.Repo, otp_app: :memento, adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    config =
      config
      |> Keyword.put(:username, System.get_env("POSTGRES_USER"))
      |> Keyword.put(:password, System.get_env("POSTGRES_PASSWORD"))
      |> Keyword.put(:hostname, System.get_env("POSTGRES_HOSTNAME"))

    {:ok, config}
  end
end
