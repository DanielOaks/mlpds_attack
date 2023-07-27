defmodule MlpdsAttack.Discord.Consumer do
  @moduledoc """
  Consumes incoming messages from Discord.
  """

  require Logger
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Interaction

  defp attack_response(attacker, victim, url, filename) do
    Logger.debug("Trying to download #{url}")

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{
          # ChannelMessageWithSource
          type: 4,
          data: %{
            content: "<@#{attacker}> attacked <@#{victim}>!",
            files: [
              %{
                name: filename,
                body: body
              }
            ]
          }
        }

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.info("404")

        %{
          # ChannelMessageWithSource
          type: 4,
          data: %{
            content: "Command failed"
          }
        }

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.info("HTTPoison error on grabbing url: #{reason}")

        %{
          # ChannelMessageWithSource
          type: 4,
          data: %{
            content: "Command failed"
          }
        }
    end
  end

  defp handle_attack(
         %Interaction{
           data: %{
             name: "attack",
             options: [
               %{type: 6} = victimOption,
               %{type: 3} = messageOption,
               %{type: 11} = mediaOption
             ],
             resolved: %{attachments: attachments}
           }
         } = interaction
       ) do
    Logger.debug(
      "Processing attack: #{victimOption.value}, #{messageOption.value}, #{mediaOption.value}"
    )

    Api.create_interaction_response(
      interaction,
      attack_response(
        interaction.user.id,
        victimOption.value,
        attachments[mediaOption.value].url,
        attachments[mediaOption.value].filename
      )
    )
  end

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
    handle_attack(interaction)
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
