defmodule Gauthic.TokenCache do
  @moduledoc """
  Behaviour/Contract that a Token Cache must implement.
  """
  alias Gauthic.{
    Token,
    FetchToken
  }

  @callback fetch(cache_name :: any(), FetchToken.t()) ::
              {:ok, Token.t()}
              | {:error, any()}

  @callback store(cache_name :: any(), Token.t()) :: :ok | {:error, any()} | :error

  @callback is_cached?(cache_name :: any(), FetchToken.t()) :: boolean()
end
