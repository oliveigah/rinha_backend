defmodule RinhaBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :rinha_backend,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RinhaBackend.Application, []}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.14"},
      {:bandit, "~> 1.0-pre"},
      {:jason, "~> 1.4"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
