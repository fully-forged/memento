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
      extra_applications: [:logger],
      mod: {Memento.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:amnesia, "~> 0.2.7"},
      {:plug_rest, "~> 0.13.0"},
      {:logster, "~> 0.4"}
    ]
  end

  defp aliases do
    [test: ["amnesia.drop -d Memento.Store", "amnesia.create -d Memento.Store --memory", "test"]]
  end
end
