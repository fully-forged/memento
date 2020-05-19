use Mix.Config

config :memento, enabled_handlers: []

config :logger, level: :error

config :memento, Memento.Repo,
  database: "memento_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :exvcr, vcr_cassette_library_dir: "test/fixture/vcr_cassettes"
