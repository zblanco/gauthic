defmodule Gauthic.Token do
  @moduledoc """
  The result of calling `Gauthic.token_for_scope` used for authorizing requests to Google API's.
  """
  alias Gauthic.Types

  @typedoc """
  A token used to authorized requests with Google APIs.
  """
  @type t() :: %__MODULE__{
          token: String.t(),
          expires: non_neg_integer(),
          sub: Types.sub(),
          scope: Types.scope(),
          account: String.t(),
          type: String.t()
        }

  defstruct [
    :token,
    :expires,
    :sub,
    :scope,
    :account,
    :type
  ]

  defimpl HTTPact.Entity, for: Gauthic.FetchToken do
    def from_response(%Gauthic.FetchToken{} = cmd, %HTTPact.Response{status: 200, body: body}) do
      with {:ok,
            %{
              "access_token" => access_token,
              "token_type" => type,
              "expires_in" => expires
            }} <- Jason.decode(body) do
        %Gauthic.Token{
          token: access_token,
          expires: expires,
          type: type,
          account: cmd.credentials.client_email,
          scope: cmd.scope
        }
      end
    end

    def from_response(%Gauthic.FetchToken{}, %HTTPact.Response{status: 400, body: body}) do
      with {:ok, error_body} <- Jason.decode(body) do
        {:error, error_body}
      end
    end
  end
end
