defmodule Gauthic.FetchToken do
  @moduledoc """
  Command Struct that translates to an HTTP Request for fetching a token against Google OAuth servers.
  """

  alias HTTPact.Request

  defstruct [
    :jwt,
    :url,
    :grant_type,
  ]

  def new(jwt, "urn:ietf:params:oauth:grant-type:jwt-bearer" = grant_type) do
    new(jwt, grant_type, "https://www.googleapis.com/oauth2/v4/token")
  end
  def new(jwt, "refresh_token" = grant_type) do
    new(jwt, grant_type, "https://www.googleapis.com/oauth2/v4/token")
  end
  def new(jwt, grant_type, url) do
    %__MODULE__{
      jwt: jwt,
      url: url,
      grant_type: grant_type,
    }
  end

  # TODO: different to_request/1 functions for refresh & compute-meta tokens
  def to_request(%__MODULE__{} = command, http_client) do
    %Request{
      method: :post,
      path: command.url,
      headers: [{"Content-Type", "application/x-www-form-urlencoded"}],
      body: URI.encode_query(%{
        "grant_type" => command.grant_type,
        "assertion" => command.jwt,
      }),
      http_client: http_client,
    }
  end

end
