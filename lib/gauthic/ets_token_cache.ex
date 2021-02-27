defmodule Gauthic.ETSTokenCache do
  @moduledoc """
  A basic token cache using ETS that implements the Gauthic.TokenCache behaviour.
  """
  use GenServer
  @behaviour Gauthic.TokenCache

  alias Gauthic.{
    Token,
    FetchToken
  }

  @impl true
  def store(cache_name, %Token{} = token) do
    with true <- :ets.insert(cache_name, {token_key(token), token, expiration(token)}) do
      :ok
    else
      _otherwise -> :error
    end
  end

  @impl true
  def is_cached?(cache_name, %FetchToken{} = token) do
    :ets.member(cache_name, token_key(token))
  end

  @impl true
  def fetch(cache_name, %FetchToken{} = cmd) do
    with [{_key, token, _exp}] <- :ets.lookup(cache_name, token_key(cmd)) do
      {:ok, token}
    else
      _otherwise ->
        {:error, "an error occurred fetching the token from the cache"}
    end
  end

  def purge(cache_name) do
    with true <- :ets.delete_all_objects(cache_name) do
      :ok
    else
      _otherwise -> :error
    end
  end

  @impl true
  def init(opts) do
    name = Keyword.get(opts, :name) || raise ArgumentError, "must supply a name"
    :ets.new(name, [:named_table, :set, :public, read_concurrency: true, write_concurrency: true])
    {:ok, %{name: name}}
  end

  defp token_key(%Token{account: account, scope: scope, sub: nil}),
    do: {account, Enum.sort(scope)}

  defp token_key(%Token{account: account, scope: scope, sub: sub}),
    do: {account, Enum.sort(scope), sub}

  defp token_key(%FetchToken{credentials: %{client_email: account}, scope: scope, sub: nil}),
    do: {account, Enum.sort(scope)}

  defp token_key(%FetchToken{credentials: %{client_email: account}, scope: scope, sub: sub}),
    do: {account, Enum.sort(scope), sub}

  defp expiration(token) do
    :timer.minutes(59)
  end
end
