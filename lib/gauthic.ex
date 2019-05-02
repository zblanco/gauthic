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

    def fetch_token(scope) when is_binary(scope) do
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
  }

  def token_for_scope(_creds, _scope, [http_client: nil]), do: {:error, "An http_client is required"}

  def token_for_scope(creds, scope, opts)
    when is_binary(scope), do: token_for_scope(creds, [scope], opts)

  def token_for_scope(%Credentials{} = creds, scope, [
    token_cache: token_cache,
    http_client: http_client,
  ]) do
    with {:error, _}     <- token_cache.find(creds, scope),
         {:ok, response} <- fetch_token(creds, scope, http_client),
         {:ok, token}    <- Token.from_response(response, creds.account, scope)
    do
      case token_cache.store() do
        {:ok, token} -> {:ok, token}
        _            -> {:ok, token}
      end
    else
      {:ok, %Token{}} = token -> {:ok, token}
      error -> error
    end
  end

  def token_for_scope(%Credentials{} = creds, scope, [http_client: http_client]) when is_list(scope) do
    case fetch_token(creds, scope, http_client) do
      {:ok, response} -> Token.from_response(response, creds.account, scope)
      error -> error
    end
  end

  def token_for_scope(creds, scope, sub, opts)
    when is_binary(scope), do: token_for_scope(creds, [scope], sub, opts)

  def token_for_scope(%Credentials{} = creds, scope, sub, [
    token_cache: token_cache,
    http_client: http_client,
  ]) when is_list(scope) do
    with {:error, _}     <- token_cache.find(creds, scope),
         {:ok, response} <- fetch_token(creds, scope, sub, http_client),
         {:ok, token}    <- Token.from_response(response, creds.account, scope)
    do
      case token_cache.store() do
        {:ok, token} -> {:ok, token}
        _            -> {:ok, token}
      end
    else
      {:ok, %Token{}} = token -> {:ok, token}
      error -> error
    end
  end

  def token_for_scope(%Credentials{} = creds, scope, sub, [http_client: http_client]) when is_list(scope) do
    case fetch_token(creds, scope, sub, http_client) do
      {:ok, response} -> Token.from_response(response, creds.account, scope)
      error -> error
    end
  end

  defp fetch_token(creds, scope, http_client) do
    creds
    |> build_jwt(scope)
    |> FetchToken.new("urn:ietf:params:oauth:grant-type:jwt-bearer")
    |> FetchToken.to_request(http_client)
    |> HTTPact.execute()
  end

  defp fetch_token(creds, scope, sub, http_client) do
    creds
    |> build_jwt(scope, sub)
    |> FetchToken.new("urn:ietf:params:oauth:grant-type:jwt-bearer")
    |> FetchToken.to_request(http_client)
    |> HTTPact.execute()
  end

  def build_jwt(%Credentials{client_email: account, private_key: key}, scope) do
    claims(account, scope) |> sign_jwt(key)
  end
  def build_jwt(%Credentials{client_email: account, private_key: key}, scope, sub) do
    claims(account, scope, sub) |> sign_jwt(key)
  end

  defp sign_jwt(claims, key) do
    signer = Joken.Signer.create("RS256", %{"pem" => key})
    {:ok, signed_jwt} = Joken.Signer.sign(claims, signer)
    signed_jwt
  end

  defp claims(account, scope) when is_binary(account) and is_list(scope) do
    iat = :os.system_time(:seconds)
    %{
      "iss" => account,
      "scope" => Enum.join(scope, " "),
      "aud" => "https://www.googleapis.com/oauth2/v4/token",
      "exp" => iat + 10,
      "iat" => iat,
    }
  end

  defp claims(account, scope, sub) do
    account
    |> claims(scope)
    |> Map.put_new("sub", sub)
  end

end
