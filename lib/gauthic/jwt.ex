defmodule Gauthic.JWT do
  @moduledoc false
  alias Gauthic.Credentials

  def build(%Credentials{client_email: account, private_key: key}, scope, nil, url) do
    claims(account, scope, url) |> sign_jwt(key)
  end

  def build(%Credentials{client_email: account, private_key: key}, scope, sub, url) do
    claims(account, scope, url, sub) |> sign_jwt(key)
  end

  defp sign_jwt(claims, key) do
    signer = Joken.Signer.create("RS256", %{"pem" => key})
    {:ok, signed_jwt} = Joken.Signer.sign(claims, signer)
    signed_jwt
  end

  defp claims(account, scope, url) when is_binary(account) and is_list(scope) do
    iat = :os.system_time(:seconds)

    %{
      "iss" => account,
      "scope" => Enum.join(scope, " "),
      "aud" => url,
      "exp" => iat + 10,
      "iat" => iat
    }
  end

  defp claims(account, scope, url, sub) do
    account
    |> claims(scope, url)
    |> Map.put_new("sub", sub)
  end
end
