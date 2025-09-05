defmodule Merlin.MixProject do
  use Mix.Project

  def project do
    [
      app: :merlin,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: Merlin.CLI, name: "merlin"]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"}
    ]
  end
end
