defmodule Gauthic.ETSTokenCache do
  @moduledoc """
  A basic token cache using ETS that implements the Gauthic.TokenCache behaviour.

  This can be configured in a supervision tree such as your `application.ex` as follows:

  ```
  # application.ex

  def start(_type, _args) do
    children = [
      {Gauthic.ETSTokenCache, name: MyApp.GauthicTokenCache},
    ]
  ```

  The name given is used to identify/register both the process and the ETS tables in the local node.

  Finally with the token cache setup in your application it can be used in `Gauthic.token_for_scope/3 calls as follows:

  ```
  Gauthic.token_for_scope(
    my_service_account_credentials,
    "https://www.googleapis.com/auth/admin.directory.user",
    token_cache: {MyApp.GauthicTokenCache, Gauthic.ETSTokenCache}
  )
  ```
  """
  use GenServer
  @behaviour Gauthic.TokenCache

  alias Gauthic.{
    Token,
    FetchToken
  }

  def start_link(opts) do
    name =
      Keyword.get(opts, :name) ||
        raise ArgumentError, "must supply a name to identify this Gauthic.ETSTokenCache process"

    GenServer.start_link(__MODULE__, name, name: name)
  end

  @impl true
  @doc """
  Stores a given token in the given cache.

  Used internally to a Gauthic.token_for_scope/3 call with a `token_cache` option such as `token_cache: {MyNamedTokenCache, Gauthic.ETSTokenCache}`.
  ```
  """
  def store(cache_name, %Token{} = token) do
    with true <- :ets.insert(cache_name, {token_key(token), token}) do
      schedule_expiration(cache_name, token)
      :ok
    else
      _otherwise -> :error
    end
  end

  @impl true
  @doc """
  Returns a boolean determining whether the given cache has a valid token for the given credentials and scopes/subs in the FetchToken command.

  Used internally to a Gauthic.token_for_scope/3 call with a `token_cache` option such as `token_cache: {MyNamedTokenCache, Gauthic.ETSTokenCache}`.
  ```
  """
  def is_cached?(cache_name, %FetchToken{} = token) do
    :ets.member(cache_name, token_key(token))
  end

  @impl true
  @doc """
  Fetches a token from the cache of a given name using the FetchToken command struct.

  Used internally to a Gauthic.token_for_scope/3 call with a `token_cache` option such as token_cache: {MyNamedTokenCache, Gauthic.ETSTokenCache}.
  ```
  """
  def fetch(cache_name, %FetchToken{} = cmd) do
    with [{_key, token}] <- :ets.lookup(cache_name, token_key(cmd)) do
      {:ok, token}
    else
      _otherwise ->
        {:error, "an error occurred fetching the token from the cache"}
    end
  end

  @doc """
  Purges all stored tokens in the cache for the given name.

  Example
  ```
  iex> Gauthic.ETSTokenCache.purge(MyGauthicTokenCache)
  iex> :ok
  ```
  """
  def purge(cache_name) do
    with true <- :ets.delete_all_objects(cache_name) do
      :ok
    else
      _otherwise -> :error
    end
  end

  @impl true
  def init(name) do
    :ets.new(name, [:named_table, :set, :public, read_concurrency: true, write_concurrency: true])
    {:ok, %{name: name}}
  end

  @impl true
  def handle_info({:expire_token, key}, state) do
    true = :ets.delete(state.name, key)
    {:noreply, state}
  end

  defp token_key(%Token{account: account, scope: scope, sub: nil}),
    do: {account, Enum.sort(scope)}

  defp token_key(%Token{account: account, scope: scope, sub: sub}),
    do: {account, Enum.sort(scope), sub}

  defp token_key(%FetchToken{credentials: %{client_email: account}, scope: scope, sub: nil}),
    do: {account, Enum.sort(scope)}

  defp token_key(%FetchToken{credentials: %{client_email: account}, scope: scope, sub: sub}),
    do: {account, Enum.sort(scope), sub}

  defp schedule_expiration(cache_name, %Token{expires: expires} = token) do
    expiration_from_in_milliseconds_with_padding = (expires - 20) * 1000

    Process.send_after(
      cache_name,
      {:expire_token, token_key(token)},
      expiration_from_in_milliseconds_with_padding
    )
  end
end
