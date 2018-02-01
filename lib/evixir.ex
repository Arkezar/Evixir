defmodule Evixir do
  use Application
  require Logger
  @moduledoc """
  Documentation for Evixir.
  """

  @doc """
  test
  ##Examples
  """
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Evixir.Router, [], port: 8080),
      worker(Evixir.Discord, [], id: 0),
      supervisor(Evixir.Repo, []),
      Evixir.ESI.Killmail
    ]

    Logger.info("Started application")

    Supervisor.start_link(children, strategy: :one_for_one)   
  end
end
