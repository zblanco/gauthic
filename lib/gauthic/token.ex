defmodule Gauthic.Token do
  @moduledoc """
  The result of calling `Gauthic.token_for_scope` used for authorizing requests to Google API's.
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

  def from_response(
    %Response{status: 200, body: body},
    account,
    scope,
    sub
  ) do
    with {:ok, %{
        "access_token" => access_token,
        "token_type" => type,
        "expires_in" => expires
      }
    } <- Jason.decode(body) do
      {:ok, %__MODULE__{
        token: access_token,
        expires: expires,
        type: type,
        sub: sub,
        scope: scope,
        account: account,
      }}
    end
  end

  def from_response(
    %Response{status: 200, body: body},
    account,
    scope
  ) do
    with {:ok, %{
        "access_token" => access_token,
        "token_type"   => type,
        "expires_in"   => expires
      }
    } <- Jason.decode(body) do
      {:ok, %__MODULE__{
        token: access_token,
        expires: expires,
        type: type,
        scope: scope,
        account: account,
      }}
    end
  end
end
