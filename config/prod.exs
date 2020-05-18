use Mix.Config

config :memento, Memento.Repo,
  database: "memento_prod",
  pool_size: 5

config :logger, level: :info
