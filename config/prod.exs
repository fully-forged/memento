use Mix.Config

config :memento, Memento.Repo,
  ssl: true,
  database: "memento_prod",
  pool_size: 5

config :memento, MementoWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  url: [scheme: "https", host: "ff-memento.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]]

config :logger, level: :info
