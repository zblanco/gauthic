defmodule GauthicTest do
  use ExUnit.Case
  doctest Gauthic

  test "greets the world" do
    assert Gauthic.hello() == :world
  end
end
