defmodule EvixirTest do
  use ExUnit.Case
  doctest Evixir

  test "greets the world" do
    assert Evixir.hello() == :world
  end
end
