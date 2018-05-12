use Mix.Config

config :memento,
  assets_namespace: "prod",
  enabled_handlers: [
    Memento.Capture.Twitter.Handler,
    Memento.Capture.Github.Handler,
    Memento.Capture.Instapaper.Handler
  ]

config :logger, level: :info
