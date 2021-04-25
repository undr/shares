defmodule Shares.Game.ActionTest do
  use ExUnit.Case

  alias Shares.Game
  alias Shares.Game.Action

  setup do
    :rand.seed(:exsplus, {1, 2, 3})
    :ok
  end

  describe ".create" do
    test "join" do
      {:ok, action} = Action.create(%{"type" => "join", "id" => "1", "name" => "undr", "preloaded" => true})
      assert %Action.Join{id: "1", name: "undr"} = action
    end

    test "start" do
      {:ok, action} = Action.create(%{"type" => "start", "index" => 1, "preloaded" => true})
      assert %Action.Start{index: 1} = action
    end

    test "sell" do
      {:ok, action} = Action.create(%{
        "type" => "sell",
        "player" => "1",
        "color" => "red",
        "quantity" => 1,
        "preloaded" => true
      })

      assert %Action.Sell{player: "1", color: "red", quantity: 1} = action
    end

    test "buy" do
      {:ok, action} = Action.create(%{
        "type" => "buy",
        "player" => "1",
        "color" => "red",
        "quantity" => 1,
        "preloaded" => true
      })

      assert %Action.Buy{player: "1", color: "red", quantity: 1} = action
    end

    test "next" do
      {:ok, action} = Action.create(%{"type" => "next", "preloaded" => true})
      assert %Action.Next{} = action
    end

    test "unknown" do
      {:error, :unsupported_action} = Action.create(%{"type" => "unknown", "any" => "args"})
    end
  end

  test ".preload" do
    game = Game.new("0")
    |> Game.put([:players, "1"], %{})
    |> Game.put([:players, "2"], %{})
    |> Game.put([:players, "3"], %{})

    assert {:ok, %Action.Start{index: 2, preloaded: true}} = Action.preload(%Action.Start{}, game)
  end

  test ".execute" do
    {:ok, game} = Action.execute(%Action.Start{index: 1, preloaded: true}, Game.new("0"))

    assert %Game{stage: {0, 0, 0, 1}, state: :playing} = game
    assert {:error, :wrong_state} = Action.execute(%Action.Start{index: 1, preloaded: true}, game)
  end
end
