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

  def set_scope(%__MODULE__{} = token, scope) do
    %__MODULE__{token | scope: scope}
  end

  def set_account(%__MODULE__{} = token, account) do
    %__MODULE__{token | account: account}
  end

  defimpl HTTPact.Entity, for: Gauthic.Token do
    def from_response(%HTTPact.Response{status: 200, body: body}) do
      with {:ok,
            %{
              "access_token" => access_token,
              "token_type" => type,
              "expires_in" => expires
            }} <- Jason.decode(body) do
        {:ok,
         %Gauthic.Token{
           token: access_token,
           expires: expires,
           type: type
         }}
      end
    end
  end
end
