defmodule Gauthic.Token do
  @moduledoc """
  A Google OAuth Token that can be used by a Client.
  """
  alias Gauthic.Types
  alias HTTPact.Response

  @typedoc """
  A token used to authorized requests with Google APIs.
  """
  @type t() :: %__MODULE__{
    token: String.t(),
    expires: non_neg_integer(),
    sub: Types.sub(),
    scope: Types.scope(),
    account: String.t(),
    type: String.t(),
  }

  defstruct [
    :token,
    :expires,
    :sub,
    :scope,
    :account,
    :type,
  ]

  # %{"access_token" => access_token, "token_type" => token_type, "expires_in" => expires_in}
  # accept json decoded map of the token returned from google auth servers
  def from_response(
    %Response{status: 200, body: body},
    account,
    scope,
    sub
  ) do
    with {:ok,
      %{"access_token" => access_token, "token_type" => type, "expires_in" => expires}
    } <- Jason.decode(body) do
      %__MODULE__{
        token: access_token,
        expires: expires,
        type: type,
        sub: sub,
        scope: scope,
        account: account,
      }
    end
  end

  def from_response(
    %Response{status: 200, body: body},
    account,
    scope
  ) do
    with {:ok,
      %{"access_token" => access_token, "token_type" => type, "expires_in" => expires}
    } <- Jason.decode(body) do
      %__MODULE__{
        token: access_token,
        expires: expires,
        type: type,
        scope: scope,
        account: account,
      }
    end
  end

end
