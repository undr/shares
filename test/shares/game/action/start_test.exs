defmodule Shares.Game.Action.StartTest do
  use ExUnit.Case

  alias Shares.Game
  alias Shares.Game.Action

  setup do
    :rand.seed(:exsplus, {1, 2, 3})
    :ok
  end

  # See Game.undo/1 for details
  # test "execute && undo" do
  #   game0 = Game.new("0")
  #   action = %Action.Start{index: 1, preloaded: true}
  #
  #   assert {:ok, game1} = Action.execute(action, game0)
  #   assert {:ok, game2} = Action.undo(action, game1)
  #   assert game0 == game2
  # end

  test ".preload" do
    game = Game.new("0")
    |> Game.put([:players, "1"], %{})
    |> Game.put([:players, "2"], %{})
    |> Game.put([:players, "3"], %{})

    {:ok, %Action.Start{index: 2, preloaded: true}} = Action.preload(%Action.Start{}, game)
    {:ok, %Action.Start{index: 2, preloaded: true}} = Action.preload(%Action.Start{}, game)
    {:ok, %Action.Start{index: 2, preloaded: true}} = Action.preload(%Action.Start{}, game)
    {:ok, %Action.Start{index: 1, preloaded: true}} = Action.preload(%Action.Start{}, game)
    {:ok, %Action.Start{index: 0, preloaded: true}} = Action.preload(%Action.Start{}, game)
  end

  describe ".execute" do
    test "success and wrong state" do
      {:ok, game} = Action.execute(%Action.Start{index: 1, preloaded: true}, Game.new("0"))

      assert %Game{stage: {0, 0, 0, 1}, state: :playing} = game
      assert {:error, :wrong_state} = Action.execute(%Action.Start{index: 1, preloaded: true}, game)
    end

    test "not preloaded" do
      :ignore = Action.execute(%Action.Start{index: 1}, Game.new("0"))
    end
  end

  # See Game.undo/1 for details
  # describe ".undo" do
  #   test "success and wrong state" do
  #     game = %{Game.new("0") | stage: {0, 0, 0, 1}, state: :playing}
  #     {:ok, game} = Action.undo(%Action.Start{index: 1, preloaded: true}, game)
  #
  #     assert %Game{stage: {0, 0, 0, nil}, state: :waiting} = game
  #     assert {:error, :wrong_state} = Action.undo(%Action.Start{index: 1, preloaded: true}, game)
  #   end
  #
  #   test "not preloaded" do
  #     :ignore = Action.undo(%Action.Start{index: 1}, Game.new("0"))
  #   end
  # end
end
