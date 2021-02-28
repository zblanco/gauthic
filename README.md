<!-- MDOC !-->

A simple Google OAuth Token utility.

Gauthic is HTTP Client agnostic, runtime configurable, and supports an injectable Token Cache.

You can use `Gauthic.token_for_scope/3` to fetch Google OAuth tokens for your Google OAuth credentials that can be used in subsequent
  requests with Google's APIs.

** Currently Gauthic only supports Service Account Bearer token flows for server to server API requests. **

To use Gauthic you will first need to [register a Google Service Account](https://developers.google.com/identity/protocols/oauth2/service-account#httprest)
  and configure your application to retrieve those credentials. All configuration of credentials for Gauthic happens through function calls
  at runtime to `Gauthic.token_for_scope/3` or by building credentials directly with `Gauthic.Credentials.new/1` meaning using different sets
  of credentials for different calls can be managed by your application as needed.

By default Gauthic makes HTTP Requests using the [Finch library](https://github.com/keathley/finch), but any `HTTPact.Client` implementation
  can be used if desired.

Gauthic supports token caching through the `Gauthic.TokenCache` behaviour and the `:token_cache` option of `Gauthic.token_for_scope/3`.
  The `Gauthic.ETSTokenCache` which utilizes Erlang Term Storage (ETS) for caching tokens can be configured for this purpose.
  It is recommended to use a cache with Gauthic in production as not doing so will mean an HTTP Request to Google's OAuth servers for every request you make.

  ## Installation & Usage Example

  First add Gauthic to your dependencies in mix.exs:

  ```elixir
  defp deps do
    [
      {:gauthic, "~> 0.1.0"},
    ]
  end
  ```

  Wrap calls to Gauthic in some utility module with logic to utilize configured credentials.

  ```elixir
  defmodule MyGoogleAPIWrapper.Auth do
    def token_for_scope(scope) when is_binary(scope) do
      Gauthic.token_for_scope(
        credentials(),
        scope,
        token_cache: {MyGoogleAPIWrapper.TokenCache, Gauthic.ETSTokenCache}
      )
    end

    def token_for_scope(scope, sub) when is_binary(scope) and is_binary(sub) do
      Gauthic.token_for_scope(
        credentials(),
        scope,
        sub: sub,
        token_cache: {MyGoogleAPIWrapper.TokenCache, Gauthic.ETSTokenCache}
      )
    end

    defp credentials() do
      {:ok, credentials} =
        Application.get_env(:my_google_api_wrapper, :service_account_credentials)
        |> File.read!()
        |> Jason.decode()

      creds
    end
  end
  ```

  See the HexDocs for `Gauthic.ETSTokenCache` for details on configuring the built-in cache to your application.