defmodule Gauthic.TokenCache do
  @moduledoc """
  Behaviour/Contract that a Token Cache must implement.
  """
  alias Gauthic.{
    Credentials,
    Token,
    Types,
  }

  @callback find(Credentials.t(), Types.scope()) ::
    {:ok, Token.t()}
    | {:error, any()}

  @callback find(Credentials.t(), Types.scope(), Types.sub()) ::
    {:ok, Token.t()}
    | {:error, any()}

  @callback store(Token.t()) :: {:ok, Token.t()} | {:error, any()}

end
