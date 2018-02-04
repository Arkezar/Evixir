defmodule Evixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :evixir,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :oauth2],
      mod: {Evixir, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.4.4"},
      {:httpotion, "~> 3.0.2"},
      {:oauth2, "~> 0.9"},
      # {:nostrum, "~> 0.1"},
      {:nostrum, git: "https://github.com/Arkezar/nostrum.git", branch: "rich_fix"},
      {:ecto, "~> 2.1"},
      {:mariaex, "~> 0.8.2"},
      {:money, "~> 1.2.1"},
      {:distillery, "~> 1.5", runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
