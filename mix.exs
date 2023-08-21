defmodule RinhaBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :rinha_backend,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mnesia],
      mod: {RinhaBackend.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.14"},
      {:bandit, "~> 1.0-pre"},
      {:elixir_uuid, "~> 1.2"},
      {:jason, "~> 1.4"}
    ]
  end
end
