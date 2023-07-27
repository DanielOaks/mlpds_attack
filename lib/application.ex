defmodule MlpdsAttack.Application do
  @moduledoc """
  The entry point for the MLPDS Attack application.
  """

  require Logger
  use Application

  @impl true
  @spec start(
          Application.start_type(),
          term()
        ) :: {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, term()}
  def start(_type, _args) do
    callback_port = String.to_integer(Application.get_env(:mlpds_attack, :callback_port))
    Logger.info("Starting callback server on port #{ callback_port }")

    children = [
      # Handles OAuth2 callbacks.
      {Plug.Cowboy, scheme: :http, plug: MlpdsAttack.CallbackServer.Router, options: [port: callback_port]},

      # Consumes discord events.
      MlpdsAttack.Discord.Consumer,

      # # Manages the PostgreSQL connection.
      # Bolt.Repo,

      # # Handles timed events of infractions.
      # {Bolt.Events.Handler, name: Bolt.Events.Handler},
      # Nosedrum.TextCommand.Storage.ETS,

      # # Allows for embed pagination.
      # {Bolt.Paginator, name: Bolt.Paginator},

      # # Caches messages for mod log purposes.
      # {Nosedrum.MessageCache.Agent, name: Bolt.MessageCache},

      # # Supervises the Uncomplicated Spam Wall processes.
      # Bolt.USWSupervisor,

      # # Supervises bolt's auto-redact worker processes.
      # Bolt.Redact.Supervisor,

      # # Manages the bolt <-> rrdtool connection.
      # Bolt.RRD,

      # # Handles Discord Gateway events.
      # Bolt.Consumer
    ]

    options = [strategy: :one_for_one, name: MlpdsAttack.Supervisor]
    Supervisor.start_link(children, options)
  end
end
