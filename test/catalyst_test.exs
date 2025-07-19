defmodule CatalystTest do
  use ExUnit.Case
  doctest Catalyst

  test "greets the world" do
    assert Catalyst.hello() == :world
  end
end
