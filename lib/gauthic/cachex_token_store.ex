defmodule Gauthic.CachexTokenStore do
  @moduledoc """
  Cachex implementation of the Token Cache behaviour.

  Caches tokens with a tuple of the client/account email, alphabetically sorted scopes, and the sub/impersonated email/account.
  Uses a TTL/Time To Live/Expiration of 59 minutes as Google OAuth Tokens last 60 minutes.

  TODO: Separate into another lib as an optional dependency with instructions to configure into your application.

  Requires adding the token store to the consuming application's children.
  """
  alias Gauthic.{Credentials, Token}

  def find(%Credentials{client_email: account}, scope) do
    case Cachex.exists?(:gauthic_token_cache, token_key(account, scope)) do
      {:ok, true} ->
        Cachex.get(:gauthic_token_cache, {account, Enum.sort(scope)})
      {:error, false} ->
        {:error, "A Cached token for this scope and account was not found"}
    end
  end

  def find(%Credentials{client_email: account}, scope, sub) do
    case Cachex.exists?(:gauthic_token_cache, token_key(account, scope, sub)) do
      {:ok, true} ->
        Cachex.get(:gauthic_token_cache, {account, Enum.sort(scope), sub})
      {:error, false} ->
        {:error, "A Cached token for this scope, account and sub was not found"}
    end
  end

  def store(%Token{} = token) do
    with {:ok, true} <- Cachex.put(:gauthic_token_cache, token_key(token), token, ttl: :timer.minutes(59)) do
      {:ok, token}
    else
      _ -> {:error, "Token caching failed"}
    end
  end

  defp token_key(%Token{account: account, scope: scope, sub: nil}), do:
    {account, Enum.sort(scope)}
  defp token_key(%Token{account: account, scope: scope, sub: sub}), do:
    {account, Enum.sort(scope), sub}
  defp token_key(account, scope), do:
    {account, Enum.sort(scope)}
  defp token_key(account, scope, sub), do:
    {account, Enum.sort(scope), sub}
end
