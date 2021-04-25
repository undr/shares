defmodule Shares.Game.PlayerTest do
  use ExUnit.Case

  alias Shares.Game.Player

  describe ".total" do
    test "with balance and shares" do
      rates = %{red: 10, blue: 20, green: 30, yellow: 40}
      shares = %{red: 1, blue: 2, green: 3, yellow: 4}
      player = %Player{id: "1", name: "undr", balance: 1000, shares: shares}

      assert 1300 == Player.total(player, rates)
    end

    test "without balance" do
      rates = %{red: 10, blue: 20, green: 30, yellow: 40}
      shares = %{red: 1, blue: 2, green: 3, yellow: 4}
      player = %Player{id: "1", name: "undr", balance: 0, shares: shares}

      assert 300 == Player.total(player, rates)
    end

    test "without shares" do
      rates = %{red: 10, blue: 20, green: 30, yellow: 40}
      shares = %{red: 0, blue: 0, green: 0, yellow: 0}
      player = %Player{id: "1", name: "undr", balance: 1000, shares: shares}

      assert 1000 == Player.total(player, rates)
    end

    test "without both" do
      rates = %{red: 10, blue: 20, green: 30, yellow: 40}
      shares = %{red: 0, blue: 0, green: 0, yellow: 0}
      player = %Player{id: "1", name: "undr", balance: 0, shares: shares}

      assert 0 == Player.total(player, rates)
    end
  end

  describe ".bankrupt?" do
    test "with balance and shares" do
      shares = %{red: 1, blue: 2, green: 3, yellow: 4}
      player = %Player{id: "1", name: "undr", balance: 1000, shares: shares}

      refute Player.bankrupt?(player)
    end

    test "without balance" do
      shares = %{red: 1, blue: 2, green: 3, yellow: 4}
      player = %Player{id: "1", name: "undr", balance: 0, shares: shares}

      refute Player.bankrupt?(player)
    end

    test "without shares" do
      shares = %{red: 0, blue: 0, green: 0, yellow: 0}
      player = %Player{id: "1", name: "undr", balance: 1000, shares: shares}

      refute Player.bankrupt?(player)
    end

    test "without both" do
      shares = %{red: 0, blue: 0, green: 0, yellow: 0}
      player = %Player{id: "1", name: "undr", balance: 0, shares: shares}

      assert Player.bankrupt?(player)
    end
  end
end
