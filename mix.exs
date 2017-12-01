defmodule Memento.MixProject do
  use Mix.Project

  def project do
    [
      app: :memento,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl],
      mod: {Memento.Application, Mix.env()}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:qdate, github: "choptastic/qdate", ref: "4c91fc4"},
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.2"},
      {:plug_rest, "~> 0.13.0"},
      {:logster, "~> 0.4"},
      {:dialyzex, "~> 1.0.0", only: :dev}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
