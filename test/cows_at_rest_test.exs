defmodule CowsAtRestTest do
  @moduledoc false

  use ExUnit.Case
  doctest CowsAtRest

  test "greets the world" do
    assert CowsAtRest.hello() == :world
  end

  test "generating all possible numbers" do
    result = CowsAtRest.Utils.cows_and_bulls_permutations()
    assert List.first(result) == [1, 0, 2, 3]
    assert List.last(result) == [9, 8, 7, 6]
    # number of candidates: 10!/6! - 9!/6!
    assert length(result) == (10 - 1) * 9 * 8 * 7
  end
end
