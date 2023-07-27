defmodule MlpdsAttack.CallbackServer.Router do
  @moduledoc """
  This router accepts OAuth2 callbacks, saving the
  access tokens from the URL.
  """
  require Logger

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/auth" do
    send_resp(conn, 200, "Welcome to my API")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
