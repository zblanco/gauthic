defmodule Gauthic.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {Finch, name: GauthicFinch}
    ]

    opts = [strategy: :one_for_one, name: Gauthic.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
