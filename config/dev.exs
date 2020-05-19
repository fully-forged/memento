use Mix.Config

config :memento, refresh_interval: 60_000 * 60

config :memento, Memento.Repo,
  database: "memento_dev",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :memento, MementoWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]
