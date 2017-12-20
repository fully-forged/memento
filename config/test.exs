use Mix.Config

config :logger, level: :error

config :memento, Memento.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER") || "postgres",
  password: System.get_env("DATA_DB_PASS") || "postgres",
  hostname: System.get_env("DATA_DB_HOST"),
  database: "memento_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :exvcr, vcr_cassette_library_dir: "test/fixture/vcr_cassettes"
