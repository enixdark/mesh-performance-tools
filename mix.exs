#!/usr/bin/env iex
defmodule MeshbluPerformanceTools.Mixfile do
  use Mix.Project

  def project do
    [app: :meshblu_performance_tools,
     version: "0.0.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: Cli],
     preferred_cli_env: [espec: :test],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      extra_applications: [:logger,:httpotion, :poison, :ibrowse, :poolboy ,:gen_mqtt, :gen_fsm],
      mod: {MeshbluPerformanceTools, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpotion, "~> 3.0.2"},
      {:poison, "~> 3.0"},
      {:poolboy, "~> 1.5.1"},
      {:ibrowse, "~> 4.4.0"},
      {:hackney, "~> 1.8"},
      {:logger_file_backend, "~> 0.0.9"},
      {:gen_mqtt, "~> 0.3.1"},
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.3.5"},
      # {:gen_stage, "~> 0.12.0"},
      {:gen_fsm, "~> 0.1.0"},
      # {:gen_state_machine, "~> 2.0"}
    ]
  end
end
