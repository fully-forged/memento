# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# You can control some aspects of the application from here.
#
# Specifically:
#
# - refresh_interval: how often to check for new data. Note that each source
#   uses an indipendent interval.
# - retry_interval: how long to wait before retrying after a failure
#   in fetching new data from a source.
# - enabled_handlers: only handlers listed here are started.

config :memento,
  ecto_repos: [Memento.Repo],
  twitter_username: "cloud8421",
  github_username: "cloud8421",
  refresh_interval: 60_000 * 5,
  retry_interval: 30_000,
  enabled_handlers: [
    Memento.Capture.Twitter.Handler,
    Memento.Capture.Github.Handler,
    Memento.Capture.Pinboard.Handler,
    Memento.Capture.Instapaper.Handler
  ]

config :memento, Memento.RateLimiter,
  max_per_interval: 2,
  reset_interval_in_ms: 10000

import_config "#{Mix.env()}.exs"
