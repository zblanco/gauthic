defmodule Gauthic do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias Gauthic.{
    Credentials,
    Token,
    FetchToken
  }

  @doc """
  Retrieves a Google OAuth Token for a given scope.

  Accepts the following options:

  * `:token_cache` - a tuple of `{cache_name, cache_implementation}` where the `cache_name` is the name of the cache registered such as `MyCache`
      and `cache_implementation` is the module that implements the `Gauthic.TokenCache` behaviour such as `Gauthic.ETSTokenCache`.
      Gauthic will not use a cache unless specified to do so, and should the cache fail
      but a request to fetch the token succeed - will still return the token.
  * `:http_client` - defaults to the `Gauthic.FinchClient` implementation,
     but will accept any http client that conforms to the HTTPact.Client behaviour.
  * `:sub` - The "substitute" or delegated authority of the user the token's subsequent requests are for. Usually an email string.

  ## Examples

      # without any options, using defaults
      my_credentials = File.read!("some_path/credentials.json")
      Gauthic.token_for_scope(my_credentials, "https://www.googleapis.com/auth/admin.directory.user")

      # using a delegated authority / sub
      Gauthic.token_for_scope(my_credentials, "https://www.googleapis.com/auth/admin.directory.user", sub: "bob.test@my_domain.com")

      # using a token cache see `Gauthic.ETSTokenCache` for a local ETS cache implementation you can use
      Gauthic.token_for_scope(my_credentials, "https://www.googleapis.com/auth/admin.directory.user", token_cache: {MyTokenCache, Gauthic.ETSTokenCache})

      # using a different implementation of an HTTPact.Client
      Gauthic.token_for_scope(my_credentials, "https://www.googleapis.com/auth/admin.directory.user", http_client: SomeOtherHTTPactClient)
  """
  def token_for_scope(creds, scope, opts \\ []) do
    {token_cache, opts} = Keyword.pop(opts, :token_cache)
    {http_client, opts} = Keyword.pop(opts, :http_client, Gauthic.FinchClient)
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
