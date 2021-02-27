defmodule Gauthic.Credentials do
  @moduledoc """
  Credentials needed for a token provider to sign and fetch tokens.

  Credentials must be provided for each `Gauthic.token_for_scope/2` and `Gauthic.token_for_scope/3` call.

  Credentials are easily built from Service Account JSON using the `new/1` function.

  ## Examples

  ```elixir
  json_credentials =
    Application.get_env(:my_google_api_integration, :service_account_credentials) # configuration for your app containing the file path of service account credentials
    |> File.read!()

  {:ok, credentials} = Gauthic.Credentials.new(json_credentials)

  # or decode the credentials yourself using the json library of your choice

  {:ok, decoded_credentials} =
    "some_path/credentials.json"
    |> File.read!()
    |> Jason.decode()

  {:ok, credentials} = Gauthic.Credentials.new(decoded_credentials)


  ```

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
    :client_x509_cert_url
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
    :client_x509_cert_url
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
          client_x509_cert_url: String.t()
        }

  @spec new(binary | map | Gauthic.Credentials.t()) ::
          {:error, Jason.DecodeError.t()} | {:ok, Gauthic.Credentials.t()}
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
        type: type
      }) do
    {:ok,
     %__MODULE__{
       auth_provider_x509_cert_url: auth_provider_x509_cert_url,
       auth_uri: auth_uri,
       client_email: client_email,
       client_id: client_id,
       client_x509_cert_url: client_x509_cert_url,
       private_key: private_key,
       private_key_id: private_key_id,
       project_id: project_id,
       token_uri: token_uri,
       type: type
     }}
  end

  def new(%__MODULE__{} = creds), do: {:ok, creds}

  def new(%{} = params) do
    atomized_params = for {key, val} <- params, into: %{}, do: {String.to_existing_atom(key), val}
    new(atomized_params)
  end

  def new(json) when is_binary(json) do
    with {:ok, params} <- Jason.decode(json) do
      new(params)
    end
  end
end
