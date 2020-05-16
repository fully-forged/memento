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
      dialyzer_warnings: dialyzer_warnings(),
      dialyzer_ignored_warnings: dialyzer_ignored_warnings(),
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
      extra_applications: [:logger, :inets, :ssl],
      mod: {Memento.Application, Mix.env()},
      start_phases: [
        create_status_table: [],
        create_rate_limiter_table: []
      ]
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
      {:jason, "~> 1.2"},
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 3.4"},
      {:ecto_sql, "~> 3.0"},
      {:plug, "~> 1.4"},
      {:cowboy, "~> 2.1"},
      {:saul, "~> 0.1.0"},
      {:oauther, "~> 1.1"},
      {:logster, "~> 1.0"},
      {:html_entities, "~> 0.5.0"},
      {:ex_doc, "~> 0.22.0", only: :dev},
      {:dialyzex, "~> 1.1", only: :dev},
      {:stream_data, "~> 0.5.0", only: :test},
      {:exvcr, "~> 0.8", only: :test}
    ]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp dialyzer_warnings do
    [:unmatched_returns, :error_handling, :race_conditions, :unknown]
  end

  defp dialyzer_ignored_warnings do
    [
      {
        :warn_contract_supertype,
        :_,
        {:extra_range, [:_, :__protocol__, 1, :_, :_]}
      }
    ]
  end
end
