defmodule CowsAtRestTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Plug.Test
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

  @opts CowsAtRest.Router.init([])

  test "game state" do
    conn = conn(:get, "/")
    conn = CowsAtRest.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200

    assert conn.resp_body ==
             Jason.encode!(%CowsAtRest.Game.GameController.State{
               log: [],
               actor_at_turn_to_ask: :player
             })
  end
end
