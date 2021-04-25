defmodule Shares.Game.Action.JoinTest do
  use ExUnit.Case

  alias Shares.Game
  alias Shares.Game.Action
  alias Shares.Game.Player

  setup do
    :rand.seed(:exsplus, {1, 2, 3})
    :ok
  end

  # See Game.undo/1 for details
  # test "execute && undo" do
  #   game = Game.new("0")
  #   action = %Action.Join{
  #     id: "zibcq6yv",
  #     name: "undr",
  #     b_cards: ["m:y", "d:y", "h:2:b"],
  #     s_cards: ["s:40:b", "s:30:r", "s:30:y", "s:50:y", "s:40:g"],
  #     shares: %{blue: 1, green: 1, red: 1, yellow: 1},
  #     preloaded: true
  #   }
  #
  #   assert {:ok, game1} = Action.execute(action, game)
  #   assert {:ok, game2} = Action.undo(action, game1)
  #   assert game == game2
  # end

  describe ".preload" do
    test "when game created with 3/5 cards rule" do
      action = %Action.Join{
        id: "1",
        name: "undr",
        b_cards: ["m:y", "d:y", "h:2:b"],
        s_cards: ["s:40:b", "s:30:r", "s:30:y", "s:50:y", "s:40:g"],
        shares: %{blue: 1, green: 1, red: 1, yellow: 1},
        preloaded: true
      }

      {:ok, ^action} = Action.preload(%Action.Join{id: "1", name: "undr"}, Game.new("0"))
    end

    test "when game created with 4/6 cards rule" do
      action = %Action.Join{
        id: "1",
        name: "undr",
        b_cards: ["m:y", "d:y", "h:2:b", "h:1:g"],
        s_cards: ["s:40:b", "s:30:r", "s:30:y", "s:50:y", "s:40:g", "s:-60:g"],
        shares: %{blue: 1, green: 1, red: 1, yellow: 1},
        preloaded: true
      }

      {:ok, ^action} = Action.preload(%Action.Join{id: "1", name: "undr"}, Game.new("0", cards: {4, 6}))
    end
  end

  describe ".execute" do
    test "success" do
      action = %Action.Join{
        id: "1",
        name: "undr",
        b_cards: ["m:y", "d:y", "h:2:b"],
        s_cards: ["s:40:b", "s:30:r", "s:30:y", "s:50:y", "s:40:g"],
        shares: %{blue: 1, green: 1, red: 1, yellow: 1},
        preloaded: true
      }

      {:ok, game} = Action.execute(action, Game.new("0"))

      assert length(game.b_cards) == 17
      assert length(game.s_cards) == 27
      assert game.owner == "1"
      assert game.players == %{
        "1" => %Player{
          id: "1",
          name: "undr",
          cards: ["m:y", "d:y", "h:2:b", "s:40:b", "s:30:r", "s:30:y", "s:50:y", "s:40:g"],
          shares: %{red: 1, blue: 1, green: 1, yellow: 1},
          balance: 0
        }
      }

      action = %Action.Join{
        id: "2",
        name: "martin",
        b_cards: ["m:r", "d:b", "h:1:b"],
        s_cards: ["s:-40:b", "s:-30:r", "s:-30:y", "s:-50:y", "s:-40:g"],
        shares: %{blue: 1, green: 1, red: 1, yellow: 1},
        preloaded: true
      }

      {:ok, game} = Action.execute(action, game)

      assert length(game.b_cards) == 14
      assert length(game.s_cards) == 22
      assert game.owner == "1"
      assert game.players == %{
        "1" => %Player{
          id: "1",
          name: "undr",
          cards: ["m:y", "d:y", "h:2:b", "s:40:b", "s:30:r", "s:30:y", "s:50:y", "s:40:g"],
          shares: %{red: 1, blue: 1, green: 1, yellow: 1},
          balance: 0
        },
        "2" => %Player{
          id: "2",
          name: "martin",
          cards: ["m:r", "d:b", "h:1:b", "s:-40:b", "s:-30:r", "s:-30:y", "s:-50:y", "s:-40:g"],
          shares: %{red: 1, blue: 1, green: 1, yellow: 1},
          balance: 0
        }
      }

      {:error, :already_joined} = Action.execute(action, game)
    end

    test "not preloaded" do
      action = %Action.Join{
        id: "1",
        name: "undr",
        b_cards: ["m:y", "d:y", "h:2:b"],
        s_cards: ["s:40:b", "s:30:r", "s:30:y", "s:50:y", "s:40:g"],
        shares: %{blue: 1, green: 1, red: 1, yellow: 1}
      }

      :ignore = Action.execute(action, Game.new("0"))
    end
  end

  # See Game.undo/1 for details
  # describe ".undo" do
  #   test "success" do
  #     game0 = %{Game.new("0") | owner: "1", b_cards: ["h:1:r"], s_cards: ["s:-40:r"]}
  #     |> Game.put([:players, "1"], %{})
  #     |> Game.put([:players, "2"], %{})
  #
  #     action = %Action.Join{
  #       id: "1",
  #       name: "undr",
  #       b_cards: ["m:y", "d:y", "h:2:b"],
  #       s_cards: ["s:40:b", "s:30:r", "s:30:y", "s:50:y", "s:40:g"],
  #       shares: %{blue: 1, green: 1, red: 1, yellow: 1},
  #       preloaded: true
  #     }
  #
  #     {:ok, game} = Action.undo(action, game0)
  #
  #     assert game.b_cards == ["d:y", "h:1:r", "h:2:b", "m:y"]
  #     assert game.s_cards == ["s:-40:r", "s:30:r", "s:30:y", "s:40:b", "s:40:g", "s:50:y"]
  #     assert game.owner == "1"
  #     assert game.players == %{"2" => %{}}
  #
  #     action = %Action.Join{id: "2", name: "martin", b_cards: [], s_cards: [], preloaded: true}
  #     {:ok, game} = Action.undo(action, game)
  #
  #     assert game.owner == nil
  #     assert game.players == %{}
  #   end
  #
  #   test "not preloaded" do
  #     action = %Action.Join{
  #       id: "1",
  #       name: "undr",
  #       b_cards: ["m:y", "d:y", "h:2:b"],
  #       s_cards: ["s:40:b", "s:30:r", "s:30:y", "s:50:y", "s:40:g"],
  #       shares: %{blue: 1, green: 1, red: 1, yellow: 1}
  #     }
  #
  #     :ignore = Action.undo(action, Game.new("0"))
  #   end
  # end
end
