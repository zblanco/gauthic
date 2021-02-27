defmodule Gauthic do
  @moduledoc """
  A simple Google OAuth Token utility.

  Gauthic is stateless by default, HTTP Client agnostic, and supports an injectable Token Cache.

  By default you must pass in an HTTP Client that conforms to `HTTPact.Client` behaviour using the `:http_client` option.

  You can optionally pass in a module that conforms to the `Gauthic.TokenCache` behaviour using the `:token_cache` option.

  ## Usage Example

  ### In mix.exs:
  ```elixir
  defp deps do
    [
      {:gauthic, "~> 0.1.0"},
    ]
  end

  ### In some kind of Auth utility module:
  ```elixir
  defmodule MyGoogleAPIWrapper.Auth do

    alias Gauthic.{Token, Credentials}

    def token_for_scope(scope) when is_binary(scope) do
      {:ok, %Token{token: token}} =
        Gauthic.fetch_authorized_token(
          credentials(),
          scope,
          Application.get_env(:my_google_api_wrapper, :delegated_authority), # sub
          http_client: Application.get_env(:my_google_api_wrapper, :http_client) # required
          token_cache: Application.get_env(:my_google_api_wrapper, :delegated_authority) # optional, but recommended
        )
      token
    end

    defp credentials() do
      {:ok, credentials} =
        Application.get_env(:my_google_api_wrapper, :service_account_credentials)
        |> File.read!()
        |> Jason.decode()

      {:ok, creds} = Credentials.new(credentials)
      creds
    end
  end
  ```
  """
  alias Gauthic.{
    Credentials,
    Token,
    FetchToken,
    Clients.MintClient
  }

  @doc """
  Retrieves a Google OAuth Token for a given scope.

  Accepts the following options:

  * `:token_cache` a tuple of {cache_name, cache} where the cache name is the term passed into TokenCache calls and the cache
      is a module that implements the Gauthic.TokenCache behaviour.
      Gauthic will not use a cache unless specified to do so, and should the cache fail
      but a request to fetch the token succeed - will still return the token.
  * `:http_client` defaults to a Mint implementation (Gauthic.MintClient), but will accept any http client that conforms to the HTTPact.Client behaviour.
  * `:sub` The "substitute" or delegated authority of the user the token's subsequent requests are for.
  """
  def token_for_scope(creds, scope, opts \\ []) do
    {token_cache, opts} = Keyword.pop(opts, :token_cache)
    {http_client, opts} = Keyword.pop(opts, :http_client, MintClient)
    {sub, _opts} = Keyword.pop(opts, :sub)

    with {:ok, creds} <- Credentials.new(creds),
         {:ok, cmd} <- FetchToken.new(creds, scope, sub, http_client),
         {:is_cached?, _cmd, nil, false} <-
           {:is_cached?, cmd, token_cache, is_cached?(cmd, token_cache)} do
      fetch_token_with_client(cmd)
    else
      {:is_cached?, cmd, token_cache, false} ->
        fetch_token_then_cache(cmd, token_cache)

      {:is_cached?, cmd, token_cache, true} ->
        fetch_token_from_cache(cmd, token_cache)

      {:error, _msg} = error ->
        error
    end
  end

  defp fetch_token_with_client(%FetchToken{http_client: http_client} = cmd) do
    with %Token{} = token <- HTTPact.execute(cmd, http_client) do
      {:ok, token}
    else
      {:error, _msg} = error -> error
      something_else -> {:error, something_else}
    end
  end

  defp fetch_token_then_cache(cmd, {cache_name, token_cache}) do
    with {:ok, token} <- fetch_token_with_client(cmd),
         {:ok, token} <- {token_cache.store(cache_name, token), token} do
      {:ok, token}
    else
      {_otherwise, token} -> {:ok, token}
    end
  end

  defp is_cached?(_cmd, nil), do: false

  defp is_cached?(cmd, {cache_name, token_cache}) when is_atom(token_cache) do
    with true <- token_cache.is_cached?(cache_name, cmd) do
      true
    else
      _otherwise -> false
    end
  end

  defp is_cached?(_cmd, _), do: false

  defp fetch_token_from_cache(cmd, {cache_name, token_cache}),
    do: token_cache.fetch(cache_name, cmd)
end
