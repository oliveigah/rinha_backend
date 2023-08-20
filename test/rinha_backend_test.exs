defmodule RinhaBackendTest do
  use ExUnit.Case
  doctest RinhaBackend

  test "greets the world" do
    assert RinhaBackend.hello() == :world
  end
end
