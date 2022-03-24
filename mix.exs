defmodule Memento.MixProject do
  use Mix.Project

  def project do
    [
      app: :memento,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      escript: escript(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: docs(),
      compilers: [:phoenix] ++ Mix.compilers(),
      dialyzer: dialyzer(),
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger, :inets, :runtime_tools, :os_mon, :ssl],
      mod: {Memento.Application, []}
    ]
  end

  def escript do
    [
      main_module: Memento.CLI,
      app: nil,
      path: "./bin/memento"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Runtime
      {:calendar, "~> 1.0"},
      {:ecto_sql, "~> 3.0"},
      {:html_entities, "~> 0.5.0"},
      {:jason, "~> 1.2"},
      {:logster, "~> 1.0"},
      {:oauther, "~> 1.1"},
      {:phoenix, "~> 1.5.1"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.3.3"},
      {:phoenix_live_view, "~> 0.14.7"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:saul, "~> 0.1.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      # Test
      {:exvcr, "~> 0.8", only: :test},
      {:floki, ">= 0.0.0", only: :test},
      {:stream_data, "~> 0.5.0", only: [:dev, :test]},
      # Tools
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.28.3", only: :dev},
      {:phoenix_live_reload, "~> 1.2", only: :dev}
    ]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end
end
