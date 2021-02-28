defmodule Gauthic.FinchClient do
  @moduledoc """
  An implementation of the HTTPact.Client behaviour using the Finch library and
    the default Finch started with Gauthic.
  """
  alias HTTPact.{Request, Response}
  @behaviour HTTPact.Client

  @impl true
  def execute(%Request{} = request) do
    finch_request =
      Finch.build(
        request.method,
        request.path,
        request.headers,
        request.body
      )

    with {:ok, finch_response} <- make_finch_request(finch_request) do
      {:ok, build_response(finch_response)}
    else
      {:error, _} = error -> error
    end
  end

  defp make_finch_request(request) do
    Finch.request(request, GauthicFinch)
  end

  defp build_response(%Finch.Response{} = finch_response) do
    struct!(Response, finch_response |> Map.from_struct())
  end
end
