defmodule Gauthic do
  @moduledoc """
  A simple Google OAuth Token utility.

  Gauthic is stateless, HTTP Client agnostic, and allows for an injectable Token Cache.

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
          Application.get_env(:my_google_api_wrapper, :delegated_authority)
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
    TokenCache,
    FetchToken,
  }

  def token_for_scope(creds, scope)
    when is_binary(scope), do: token_for_scope(creds, [scope])

  def token_for_scope(%Credentials{} = creds, scope) when is_list(scope) do
    case TokenCache.find(creds, scope) do
      {:error, _}  -> fetch_and_cache(creds, scope)
      {:ok, token} -> {:ok, token}
    end
  end

  def token_for_scope(creds, scope, sub)
    when is_binary(scope), do: token_for_scope(creds, [scope], sub)

  def token_for_scope(%Credentials{} = creds, scope, sub) when is_list(scope) do
    case TokenCache.find(creds, scope, sub) do
      {:error, _}  -> fetch_and_cache(creds, scope, sub)
      {:ok, token} -> {:ok, token}
    end
  end

  defp fetch_and_cache(creds, scope) do
    with {:ok, response} <-
      creds
      |> build_jwt(scope)
      |> FetchToken.new("urn:ietf:params:oauth:grant-type:jwt-bearer")
      |> FetchToken.to_request()
      |> HTTPact.execute()
    do
      token =
        response
        |> Token.from_response(creds.account, scope)
        |> TokenCache.store()
      {:ok, token}
    end
  end

  defp fetch_and_cache(creds, scope, sub) do
    with {:ok, response} <-
      creds
      |> build_jwt(scope, sub)
      |> FetchToken.new("urn:ietf:params:oauth:grant-type:jwt-bearer")
      |> FetchToken.to_request()
      |> HTTPact.execute()
    do
      token =
        response
        |> Token.from_response(creds.account, scope, sub)
        |> TokenCache.store()
      {:ok, token}
    end
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
    claims = claims(account, scope)
    %{claims | "sub" => sub}
  end

end
