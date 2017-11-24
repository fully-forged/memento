use Mix.Config

config :logger, level: :error

config :memento, Memento.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  hostname: System.get_env("DATA_DB_HOST"),
  database: "memento_test",
  pool: Ecto.Adapters.SQL.Sandbox
