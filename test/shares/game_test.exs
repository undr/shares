defmodule Shares.GameTest do
  use ExUnit.Case

  alias Shares.Game
  alias Shares.Game.Cards
  alias Shares.Game.Action
  alias Shares.Game.Options

  describe ".new/2" do
    test "without opts" do
      game = Game.new("id")

      assert game.id == "id"
      assert game.opts == %Options{}
      assert game.actions == []
      assert game.b_cards == Cards.big()
      assert game.s_cards == Cards.small()
      assert game.players == %{}
      assert game.owner == nil
      assert game.rates == %{blue: 100, green: 100, red: 100, yellow: 100}
      assert game.stage == {0, 0, 0, nil}
      assert game.state == :waiting
      assert game.winners == []
    end

    test "with opts" do
      game = Game.new("id", [max_players: 3, cards: {4, 6}, rounding: :ceil])

      assert game.id == "id"
      assert game.opts == %Options{max_players: 3, cards: {4, 6}, rounding: :ceil}
      assert game.actions == []
      assert game.b_cards == Cards.big()
      assert game.s_cards == Cards.small()
      assert game.players == %{}
      assert game.owner == nil
      assert game.rates == %{blue: 100, green: 100, red: 100, yellow: 100}
      assert game.stage == {0, 0, 0, nil}
      assert game.state == :waiting
      assert game.winners == []
    end
  end

  test ".push_action/2" do
    action1 = Action.create(%{"type" => "join", "id" => "1", "name" => "test1"})
    action2 = Action.create(%{"type" => "join", "id" => "2", "name" => "test2"})
    game = %Game{}

    assert {:ok, game} = Game.push_action(game, action1)
    assert game.actions == [action1]
    assert {:ok, game} = Game.push_action(game, action2)
    assert game.actions == [action2, action1]
  end

  test ".pop_action/1" do
    action1 = Action.create(%{"type" => "join", "id" => "1", "name" => "test1"})
    action2 = Action.create(%{"type" => "join", "id" => "2", "name" => "test2"})
    game = %Game{actions: [action2, action1]}

    assert {:ok, game, ^action2} = Game.pop_action(game)
    assert game.actions == [action1]
    assert {:ok, game, ^action1} = Game.pop_action(game)
    assert game.actions == []
    assert :empty = Game.pop_action(game)
    assert game.actions == []
  end
end
