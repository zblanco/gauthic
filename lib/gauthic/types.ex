defmodule Gauthic.Types do
  @moduledoc """
  Common Types within Gauthic
  """

  @typedoc """
  OAuth 2.0 scope/URL you need to request for access to an API

  See [here for available scopes](https://developers.google.com/identity/protocols/googlescopes)

  In the JWT claim-set the scope is a space-delimited list of the URL/permissions.

  Within Gauthic, the scope is represented as a list of strings for ease of use in consuming applications.
  """
  @type scope() :: list(String.t())

  @typedoc """
  Email address of the Google Account for which Authority is delegated / impersonated / substituted.

  This is a necessary attribute to many Service Account and GSuite based authorizations.
  """
  @type sub() :: String.t()
end
