defmodule Shares.Game.Action.ValidatorTest do
  use ExUnit.Case

  alias Shares.Game
  alias Shares.Game.Player
  alias Shares.Game.Action.Validator

  test ".validate_state" do
    game = Game.new("0")

    assert :ok == Validator.validate_state(game, :waiting)
    assert :ok == Validator.validate_state(game, [:waiting, :done])
    assert {:error, :wrong_state} == Validator.validate_state(game, :playing)
    assert {:error, :wrong_state} == Validator.validate_state(game, [:playing, :finale])
    assert {:error, :wrong_state} == Validator.validate_state(game, [])
  end

  test ".validate_phase" do
    game = Game.new("0")

    assert :ok == Validator.validate_phase(game, [0])
    assert :ok == Validator.validate_phase(game, [0, 2])
    assert {:error, :wrong_phase} == Validator.validate_phase(game, [1])
    assert {:error, :wrong_phase} == Validator.validate_phase(game, [])
  end

  test ".validate_player_turn" do
    game = %{Game.new("0") | stage: {0, 0, 0, 1}}
    |> Game.put([:players, "1"], %Player{id: "1"})
    |> Game.put([:players, "2"], %Player{id: "2"})

    assert :ok == Validator.validate_player_turn(game, "2")
    assert {:error, :wrong_player} == Validator.validate_player_turn(game, "1")
    assert {:error, :wrong_player} == Validator.validate_player_turn(game, "3")
  end

  test ".validate_joining" do
    game = Game.new("0")
    |> Game.put([:players, "1"], %Player{id: "1"})

    assert :ok == Validator.validate_joining(game, "1")
    assert {:error, :not_joined} == Validator.validate_joining(game, "2")
  end

  test ".validate_no_joining" do
    game = Game.new("0")
    |> Game.put([:players, "1"], %Player{id: "1"})

    assert :ok == Validator.validate_no_joining(game, "2")
    assert {:error, :already_joined} == Validator.validate_no_joining(game, "1")
  end

  test ".validate_color" do
    assert :ok == Validator.validate_color(:red)
    assert :ok == Validator.validate_color(:blue)
    assert :ok == Validator.validate_color(:green)
    assert :ok == Validator.validate_color(:yellow)
    assert {:error, :wrong_color} == Validator.validate_color("red")
    assert {:error, :wrong_color} == Validator.validate_color(:black)
  end

  describe ".validate_deal" do
    test "shares" do
      game = %{Game.new("0") | stage: {0, 0, 0, 0}}
      |> Game.put([:players, "1"], %Player{id: "1", shares: %{red: 1}})

      assert :ok == Validator.validate_deal(:shares, game, :red, 1)
      assert {:error, :negative_quantity} == Validator.validate_deal(:shares, game, :red, -2)
      assert {:error, :insufficient_shares} == Validator.validate_deal(:shares, game, :red, 2)
    end

    test "balance" do
      game = %{Game.new("0") | stage: {0, 0, 0, 0}}
      |> Game.put([:rates, :red], 100)
      |> Game.put([:players, "1"], %Player{id: "1", shares: %{red: 1}, balance: 100})

      assert :ok == Validator.validate_deal(:balance, game, :red, 1)
      assert {:error, :negative_quantity} == Validator.validate_deal(:balance, game, :red, -2)
      assert {:error, :insufficient_funds} == Validator.validate_deal(:balance, game, :red, 2)
    end
  end

  test ".validate_card" do
    game = %{Game.new("0") | stage: {0, 0, 0, 1}}
    |> Game.put([:players, "1"], %Player{id: "1", cards: ["xxx", "xxl"]})
    |> Game.put([:players, "2"], %Player{id: "2", cards: ["xxx"]})

    assert :ok == Validator.validate_card(game, "xxx")
    assert {:error, :wrong_card} == Validator.validate_card(game, "xxl")
  end
end
