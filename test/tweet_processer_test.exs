defmodule TweetProcesserTest do
  use ExUnit.Case
  doctest TweetProcesser

  test "greets the world" do
    assert TweetProcesser.hello() == :world
  end
end
