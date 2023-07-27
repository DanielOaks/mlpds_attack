defmodule MlpdsAttack.Discord.Commands do
  @moduledoc """
  Sets up commands.
  """

  require Logger

  alias Nostrum.Api
  alias Nostrum.Constants.ApplicationCommandOptionType, as: OptionType

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
end
