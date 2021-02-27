defmodule Gauthic.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/zblanco/gauthic"

  def project do
    [
      app: :gauthic,
      version: @version,
      elixir: "~> 1.8",
      name: "Gauthic",
      description: "A minimal Google OAuth Token library",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
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
      {:ex_doc, "~> 0.21", only: :docs},
      {:jason, "~> 1.1"},
      {:joken, "~> 2.0"},
      {:finch, "~> 0.6"},
      {:httpact, github: "zblanco/httpact"},
    ]
  end

  defp docs do
    [
      main: "Gauthic",
      source_ref: "v#{@version}",
      source_url: @url
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{"GitHub" => @url}
    }
  end
end
