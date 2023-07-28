defmodule MlpdsAttack.Discord.Commands do
  @moduledoc """
  Sets up commands.
  """

  require Logger

  alias Nostrum.Api
  alias Nostrum.Constants.ApplicationCommandOptionType, as: OptionType
  alias Nostrum.Struct.Interaction

  defp attack_command() do
    %{
      name: "attack",
      description: "Send another user an attack",
      options: [
        %{
          type: OptionType.user(),
          name: "victim",
          description: "Who is being attacked",
          required: true
        },
        %{
          type: OptionType.string(),
          name: "message",
          description: "Attach a message to your attack",
          required: true
        },
        %{
          type: OptionType.attachment(),
          name: "image_or_video",
          description: "Show off your creativity",
          required: true
        }
      ]
    }
  end

  def register_on_guild(guild_id) do
    Logger.debug("Registering commands on #{guild_id}")

    # https://kraigie.github.io/nostrum/application_commands.html
    Api.create_guild_application_command(guild_id, attack_command())
  end

  def handle_attack(
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
        attachments[mediaOption.value].filename,
        messageOption.value
      )
    )
  end

  defp attack_response(attacker, victim, url, filename, message) do
    Logger.debug("Trying to download #{url}")

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{
          # ChannelMessageWithSource
          type: 4,
          data: %{
            content: "<@#{attacker}> attacked <@#{victim}>!\n#{message}",
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
end
