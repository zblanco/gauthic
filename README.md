# Gauthic

A helper library for building and fetching Google OAuth tokens in [Service Account based flows](https://developers.google.com/identity/protocols/OAuth2ServiceAccount).

Gauthic was designed to be agnostic and flexible to your choice of HTTP Client, Caching, and method of providing Service Account Credentials. Gauthic does this by using the [HTTPact](https://github.com/zblanco/httpact) Contract instead of depending on a concrete HTTP client, passing configuration like `Credentials` through function parameters, and being stateless by default.

Guathic provides a `TokenCache` behaviour so Gauthic can be configured to minimize work rebuilding and refetching tokens for each request. You can use [GauthicTokenCachex]() to do so.

### **Warning** HTTPact is still in-development and experimental, so it's recommended to use the [Goth](https://github.com/peburrows/goth) until otherwise.

## Usage

1. Add Gauthic to your dependencies:

```elixir
def deps do
  [
    {:gauthic, "~> 0.1.0"},
  ]
end
```

2. (Optional) add a Gauthic `TokenCache` such as [GauthicTokenCachex]() to your `mix.exs`

```elixir
def deps do
  [
    ...
    {:gauthic, "~> 0.1.0"},
    {:gauthic_token_cachex, "~> 0.1.0"},
  ]
end
```

and to your supervisor tree:

```elixir
children = [
  {GauthicTokenCachex, []}
]
```

3. Call `Gauthic.fetch_token` with Credentials, and the scope of the Google API Request

```elixir

# Explicitly pass HTTP Client Module
{:ok, token} = Gauthic.token_for_scope(
  credentials,
  scope,
  sub: sub,
  http_client: HTTPoisonPact,
)

# Configure from Application.env
{:ok, token} = Gauthic.token_for_scope(
  credentials,
  scope,
  sub: sub,
  http_client: Application.get_env(:my_google_api_wrapper, :http_client),
)

```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gauthic` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gauthic, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/gauthic](https://hexdocs.pm/gauthic).

