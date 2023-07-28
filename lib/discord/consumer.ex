defmodule MlpdsAttack.Discord.Consumer do
  @moduledoc """
  Consumes incoming messages from Discord.
  """

  require Logger
  use Nostrum.Consumer

  alias Nostrum.Struct.Interaction

  def handle_event({:READY, msg, _ws_state}) do
    Logger.info("Discord connection is ready")

    for guild <- msg.guilds do
      MlpdsAttack.Discord.Commands.register_on_guild(guild.id)
    end
  end

  def handle_event(
        {:INTERACTION_CREATE, %Interaction{data: %{name: "attack"}} = interaction, _ws_state}
      ) do
    Logger.info("Attack found!")
    MlpdsAttack.Discord.Commands.handle_attack(interaction)
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
