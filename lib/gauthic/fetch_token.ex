defmodule Gauthic.FetchToken do
  @moduledoc """
  Command Struct that translates to an HTTP Request for fetching a token against Google OAuth servers.
  """

  alias HTTPact.Request
  alias Gauthic.Credentials
  alias Gauthic.JWT
  alias Gauthic.Types

  @type t :: %__MODULE__{
          credentials: Credentials.t(),
          scope: Types.scope(),
          sub: Types.sub() | nil,
          http_client: module(),
          url: binary(),
          jwt: any(),
          grant_type: binary()
        }

  defstruct [
    :credentials,
    :scope,
    :sub,
    :http_client,
    :url,
    :jwt,
    :grant_type
  ]

  @spec new(
          Gauthic.Credentials.t(),
          scope :: binary | maybe_improper_list,
          sub :: binary | nil,
          http_client :: module(),
          type :: atom
        ) ::
          {:ok, Gauthic.FetchToken.t()}
  def new(%Credentials{} = creds, scope, sub, http_client, type \\ :bearer) do
    grant_type = grant_type(type)
    scope = scope(scope)
    url = url(grant_type)
    jwt = JWT.build(creds, scope, sub, url)

    {:ok,
     %__MODULE__{
       credentials: creds,
       scope: scope,
       http_client: http_client,
       grant_type: grant_type,
       url: url,
       sub: sub,
       jwt: jwt
     }}
  end

  defp scope(scope) when is_list(scope), do: scope
  defp scope(scope) when is_binary(scope), do: [scope]

  # defp grant_type(type) when type in [:bearer], do: grant_type(type)
  # defp grant_type(:bearer), do: "urn:ietf:params:oauth:grant-type:jwt-bearer"
  # defp grant_type(_), do: grant_type(:bearer)
  defp grant_type(_), do: "urn:ietf:params:oauth:grant-type:jwt-bearer"

  defp url("urn:ietf:params:oauth:grant-type:jwt-bearer"),
    do: "https://www.googleapis.com/oauth2/v4/token"

  defimpl HTTPact.Command, for: Gauthic.FetchToken do
    def to_request(%Gauthic.FetchToken{} = cmd) do
      %Request{
        method: :post,
        path: cmd.url,
        headers: [{"Content-Type", "application/x-www-form-urlencoded"}],
        body:
          URI.encode_query(%{
            "grant_type" => cmd.grant_type,
            "assertion" => cmd.jwt
          })
      }
    end
  end
end
