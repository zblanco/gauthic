defmodule Gauthic.Credentials do
  @moduledoc """
  Credentials needed for a token provider to sign and fetch tokens.

  Credentials must be provided for each `fetch_authorized_token` call.

  As you're typically provided a JSON file with the Service Account Credentials you might build the struct like follows:

  ```elixir
  {:ok, decoded_credentials} =
    Application.get_env(:my_google_api_integration, :service_account_credentials)
    |> File.read!()
    |> Jason.decode()

  {:ok, credentials} = Gauthic.Credentials.new(decoded_credentials)
  ```

  Where your config might point to a path like this:
  ```elixir
  ...
  config :my_google_integration,
    service_account_credentials: System.get_env("MY_GOOGLE_INTEGRATION_APP_CREDENTIALS")
  """
  @enforce_keys [
    :type,
    :project_id,
    :private_key_id,
    :private_key,
    :client_email,
    :client_id,
    :auth_uri,
    :token_uri,
    :auth_provider_x509_cert_url,
    :client_x509_cert_url,
  ]

  defstruct [
    :type,
    :project_id,
    :private_key_id,
    :private_key,
    :client_email,
    :client_id,
    :auth_uri,
    :token_uri,
    :auth_provider_x509_cert_url,
    :client_x509_cert_url,
  ]

  @type t() :: %__MODULE__{
    type: String.t(),
    project_id: String.t(),
    private_key_id: String.t(),
    private_key: String.t(),
    client_email: String.t(),
    client_id: String.t(),
    auth_uri: String.t(),
    token_uri: String.t(),
    auth_provider_x509_cert_url: String.t(),
    client_x509_cert_url: String.t(),
  }

  def new(%{
    auth_provider_x509_cert_url: auth_provider_x509_cert_url,
    auth_uri: auth_uri,
    client_email: client_email,
    client_id: client_id,
    client_x509_cert_url: client_x509_cert_url,
    private_key: private_key,
    private_key_id: private_key_id,
    project_id: project_id,
    token_uri: token_uri,
    type: type,
  }) do
    {:ok, %__MODULE__{
      auth_provider_x509_cert_url: auth_provider_x509_cert_url,
      auth_uri: auth_uri,
      client_email: client_email,
      client_id: client_id,
      client_x509_cert_url: client_x509_cert_url,
      private_key: private_key,
      private_key_id: private_key_id,
      project_id: project_id,
      token_uri: token_uri,
      type: type,
    }
  }
  end
  def new(%{} = params) do
    atomized_params = for {key, val} <- params, into: %{}, do: {String.to_atom(key), val}
    new(atomized_params)
  end

end
