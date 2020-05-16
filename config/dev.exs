use Mix.Config

config :memento, refresh_interval: 60_000 * 60

config :memento, Memento.Repo,
  database: "memento_dev",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
