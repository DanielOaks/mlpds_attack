defmodule MlpdsAttack.Discord.Consumer do
  @moduledoc """
  Consumes incoming messages from Discord.
  """

  require Logger
  use Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:READY, msg, _ws_state}) do
    Logger.info("Discord connection is ready")
    for guild <- msg.guilds do
      MlpdsAttack.Discord.Commands.register_on_guild(guild.id)
    end
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Logger.info(msg)
    case msg.content do
      "!sleep" ->
        Api.create_message(msg.channel_id, "Going to sleep...")
        # This won't stop other events from being handled.
        Process.sleep(3000)

      "!ping" ->
        Api.create_message(msg.channel_id, "response!")

      "!raise" ->
        # This won't crash the entire Consumer.
        raise "No problems here!"

      _ ->
        :ignore
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
