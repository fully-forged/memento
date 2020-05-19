defmodule Memento.Repo do
  @moduledoc false

  use Ecto.Repo, otp_app: :memento, adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    config =
      case System.get_env("DATABASE_URL") do
        nil ->
          config
          |> Keyword.put(:username, System.get_env("POSTGRES_USER"))
          |> Keyword.put(:password, System.get_env("POSTGRES_PASSWORD"))
          |> Keyword.put(:hostname, System.get_env("POSTGRES_HOSTNAME"))

        url ->
          Keyword.put(config, :url, url)
      end

    {:ok, config}
  end
end
