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
        create_status_table: []
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
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.2"},
      {:plug, "~> 1.4"},
      {:cowboy, "~> 1.1.0"},
      {:saul, "~> 0.1.0"},
      {:oauther, "~> 1.1"},
      {:logster, "~> 0.4"},
      {:html_entities, "~> 0.4.0"},
      {:ex_doc, "~> 0.18.1", only: :dev},
      {:dialyzex, "~> 1.1.0", only: :dev},
      {:stream_data, "~> 0.4.0", only: :test},
      {:exvcr, "~> 0.8", only: :test}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
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
