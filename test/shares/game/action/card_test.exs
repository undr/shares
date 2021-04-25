defmodule Shares.Game.Action.CardTest do
  use ExUnit.Case

  alias Shares.Game
  alias Shares.Game.Action
  alias Shares.Game.Player

  test ".preload" do
    action = %Action.Card{player: "2", card: "s:50:r", payload: %{"color" => "blue"}, preloaded: true}
    {:ok, ^action} = Action.preload(%Action.Card{player: "2", card: "s:50:r", payload: %{"color" => "blue"}}, %Game{})
  end

  describe ".execute" do
    test "success" do
      rates = %{red: 100, blue: 100, green: 100, yellow: 100}
      shares = %{red: 1, blue: 1, green: 1, yellow: 1}
      action = %Action.Card{player: "2", card: "s:50:r", payload: %{"color" => "blue"}, preloaded: true}

      game0 = %{Game.new("0") | stage: {1, 0, 0, 1}, rates: rates, state: :playing}
      |> Game.put([:players, "1"], %Player{id: "1", balance: 100, shares: shares})
      |> Game.put([:players, "2"], %Player{id: "2", balance: 100, shares: shares})

      assert {:ok, game1} = Action.execute(action, game0)

      assert game1.rates == %{red: 150, blue: 60, green: 100, yellow: 100}
      assert Game.get(game1, [:players, "1", :balance]) == 100
      assert Game.get(game1, [:players, "2", :balance]) == 140
    end
  end
end
