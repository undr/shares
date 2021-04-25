defmodule Shares.Game.Action.BuyTest do
  use ExUnit.Case

  alias Shares.Game
  alias Shares.Game.Action
  alias Shares.Game.Player

  # See Game.undo/1 for details
  # test "execute && undo" do
  #   game = %{Game.new("0") | stage: {0, 0, 0, 1}, state: :playing}
  #   |> Game.put([:players, "1"], %Player{id: "1", balance: 100, shares: %{red: 2}})
  #   |> Game.put([:players, "2"], %Player{id: "2", balance: 100, shares: %{red: 2}})
  #
  #   action = %Action.Buy{player: "2", color: "red", quantity: 2, preloaded: true}
  #
  #   assert {:ok, game1} = Action.execute(action, game)
  #   assert {:ok, game2} = Action.undo(action, game1)
  #   assert game == game2
  # end

  test ".preload" do
    action = %Action.Buy{player: "2", color: "red", quantity: 2, preloaded: true}
    {:ok, ^action} = Action.preload(%Action.Buy{player: "2", color: "red", quantity: 2}, %Game{})
  end

  describe ".execute" do
    test "success in phase 0" do
      action = %Action.Buy{player: "2", color: "red", quantity: 2, preloaded: true}

      game = %{Game.new("0") | stage: {0, 0, 0, 1}, state: :playing}
      |> Game.put([:rates, :red], 100)
      |> Game.put([:players, "1"], %Player{id: "1", balance: 200, shares: %{red: 2}})
      |> Game.put([:players, "2"], %Player{id: "2", balance: 200, shares: %{red: 2}})

      {:ok, game} = Action.execute(action, game)

      assert %Player{id: "1", balance: 200, shares: %{red: 2}} = Game.get(game, [:players, "1"])
      assert %Player{id: "2", balance: 0, shares: %{red: 4}} = Game.get(game, [:players, "2"])
    end

    test "success in phase 2" do
      action = %Action.Buy{player: "2", color: "red", quantity: 2, preloaded: true}

      game = %{Game.new("0") | stage: {2, 0, 0, 1}, state: :playing}
      |> Game.put([:rates, :red], 100)
      |> Game.put([:players, "1"], %Player{id: "1", balance: 200, shares: %{red: 2}})
      |> Game.put([:players, "2"], %Player{id: "2", balance: 200, shares: %{red: 2}})

      {:ok, game} = Action.execute(action, game)

      assert %Player{id: "1", balance: 200, shares: %{red: 2}} = Game.get(game, [:players, "1"])
      assert %Player{id: "2", balance: 0, shares: %{red: 4}} = Game.get(game, [:players, "2"])
    end

    test "fail in phase 1" do
      action = %Action.Buy{player: "2", color: "red", quantity: 2, preloaded: true}

      game = %{Game.new("0") | stage: {1, 0, 0, 1}, state: :playing}

      {:error, :wrong_phase} = Action.execute(action, game)
    end

    test "fail with wrong state" do
      action = %Action.Buy{player: "2", color: "red", quantity: 2, preloaded: true}
      {:error, :wrong_state} = Action.execute(action, %{Game.new("0") | state: :waiting})

      action = %Action.Buy{player: "2", color: "red", quantity: 2, preloaded: true}
      {:error, :wrong_state} = Action.execute(action, %{Game.new("0") | state: :finale})

      action = %Action.Buy{player: "2", color: "red", quantity: 2, preloaded: true}
      {:error, :wrong_state} = Action.execute(action, %{Game.new("0") | state: :done})
    end

    test "fail with wrong player" do
      action = %Action.Buy{player: "2", color: "red", quantity: 2, preloaded: true}

      game = %{Game.new("0") | stage: {0, 0, 0, 0}, state: :playing}
      |> Game.put([:rates, :red], 100)
      |> Game.put([:players, "1"], %Player{id: "1", balance: 100, shares: %{red: 2}})
      |> Game.put([:players, "2"], %Player{id: "2", balance: 100, shares: %{red: 2}})

      {:error, :wrong_player} = Action.execute(action, game)
    end

    test "fail with wrong color" do
      action = %Action.Buy{player: "2", color: "brown", quantity: 2, preloaded: true}

      game = %{Game.new("0") | stage: {0, 0, 0, 1}, state: :playing}
      |> Game.put([:rates, :red], 100)
      |> Game.put([:players, "1"], %Player{id: "1", balance: 100, shares: %{red: 2}})
      |> Game.put([:players, "2"], %Player{id: "2", balance: 100, shares: %{red: 2}})

      {:error, :wrong_color} = Action.execute(action, game)
    end

    test "fail with negative quantity" do
      action = %Action.Buy{player: "2", color: "red", quantity: -2, preloaded: true}

      game = %{Game.new("0") | stage: {0, 0, 0, 1}, state: :playing}
      |> Game.put([:rates, :red], 100)
      |> Game.put([:players, "1"], %Player{id: "1", balance: 100, shares: %{red: 2}})
      |> Game.put([:players, "2"], %Player{id: "2", balance: 100, shares: %{red: 2}})

      {:error, :negative_quantity} = Action.execute(action, game)
    end

    test "fail with insufficient funds" do
      action = %Action.Buy{player: "2", color: "red", quantity: 2, preloaded: true}

      game = %{Game.new("0") | stage: {0, 0, 0, 1}, state: :playing}
      |> Game.put([:rates, :red], 100)
      |> Game.put([:players, "1"], %Player{id: "1", balance: 100, shares: %{red: 2}})
      |> Game.put([:players, "2"], %Player{id: "2", balance: 100, shares: %{red: 2}})

      {:error, :insufficient_funds} = Action.execute(action, game)
    end
  end
end
