defmodule GoogleAuthMock do
  @moduledoc """
  An HTTPact Client that returns canned responses mimicking the Google Auth servers.
  """
  @behaviour HTTPact.Client
  alias HTTPact.{Request, Response}

  def execute(%Request{
    method: :post,
    path: _url,
    headers: [{"Content-Type", "application/x-www-form-urlencoded"}],
    body: _body,
  } = request) do
    %Response{

    }
  end
end
