defmodule GoogleAuthMock do
  @moduledoc """
  An HTTPact Client that returns canned responses mimicking the Google Auth servers.
  """
  @behaviour HTTPact.Client
  alias HTTPact.{Request, Response}

  def execute(%Request{
    method: :post,
    path: _path,
    headers: _headers,
    body: _body,
  }) do
    {:ok, %Response{
      status: 200,
      body: Jason.encode!(%{
        "access_token" => "some_access_token",
        "token_type"   => "Bearer",
        "expires_in"   => 3600,
      })
    }}
  end
end
