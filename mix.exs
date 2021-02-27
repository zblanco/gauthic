defmodule Gauthic.MixProject do
  use Mix.Project

  def project do
    [
      app: :gauthic,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Gauthic.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:joken, "~> 2.0"},
      {:mint, "~> 1.2"},
      {:httpact, github: "zblanco/httpact"},
    ]
  end
end
