defmodule Shares.Game.CardTest do
  use ExUnit.Case

  alias Shares.Game.Card

  describe ".parse" do
    test "small card" do
      assert {:ok, %Card{id: "s:60:r", amount: 60, color: :red, type: :small}} = Card.parse("s:60:r")
      assert {:ok, %Card{id: "s:60:b", amount: 60, color: :blue, type: :small}} = Card.parse("s:60:b")
      assert {:ok, %Card{id: "s:60:g", amount: 60, color: :green, type: :small}} = Card.parse("s:60:g")
      assert {:ok, %Card{id: "s:60:y", amount: 60, color: :yellow, type: :small}} = Card.parse("s:60:y")
      assert {:ok, %Card{id: "s:-60:r", amount: -60, color: :red, type: :small}} = Card.parse("s:-60:r")
      assert {:error, :invalid} = Card.parse("s:xx:r")
      assert {:error, :invalid} = Card.parse("s:60:x")
    end

    test "divide card" do
      assert {:ok, %Card{id: "d:r", amount: nil, color: :red, type: :divide}} = Card.parse("d:r")
      assert {:ok, %Card{id: "d:b", amount: nil, color: :blue, type: :divide}} = Card.parse("d:b")
      assert {:ok, %Card{id: "d:g", amount: nil, color: :green, type: :divide}} = Card.parse("d:g")
      assert {:ok, %Card{id: "d:y", amount: nil, color: :yellow, type: :divide}} = Card.parse("d:y")
      assert {:error, :invalid} = Card.parse("dr")
      assert {:error, :invalid} = Card.parse("d:x")
    end

    test "multi card" do
      assert {:ok, %Card{id: "m:r", amount: nil, color: :red, type: :multi}} = Card.parse("m:r")
      assert {:ok, %Card{id: "m:b", amount: nil, color: :blue, type: :multi}} = Card.parse("m:b")
      assert {:ok, %Card{id: "m:g", amount: nil, color: :green, type: :multi}} = Card.parse("m:g")
      assert {:ok, %Card{id: "m:y", amount: nil, color: :yellow, type: :multi}} = Card.parse("m:y")
      assert {:error, :invalid} = Card.parse("mr")
      assert {:error, :invalid} = Card.parse("m:x")
    end

    test "hundred card" do
      assert {:ok, %Card{id: "h:1:r", amount: nil, color: :red, type: :hundred}} = Card.parse("h:1:r")
      assert {:ok, %Card{id: "h:2:r", amount: nil, color: :red, type: :hundred}} = Card.parse("h:2:r")
      assert {:ok, %Card{id: "h:1:b", amount: nil, color: :blue, type: :hundred}} = Card.parse("h:1:b")
      assert {:ok, %Card{id: "h:1:g", amount: nil, color: :green, type: :hundred}} = Card.parse("h:1:g")
      assert {:ok, %Card{id: "h:1:y", amount: nil, color: :yellow, type: :hundred}} = Card.parse("h:1:y")
      assert {:error, :invalid} = Card.parse("h:x:r")
      assert {:error, :invalid} = Card.parse("h:4:r")
      assert {:error, :invalid} = Card.parse("h:1:x")
    end
  end

  describe ".rules" do
    test "small -60" do
      assert {:ok, rules} = Card.rules("s:-60:r", %{"color" => "yellow"})

      assert rules[:red].(100, :floor) == %{diff: -60, new: 40, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: 30, new: 130, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: 0, new: 100, old: 100}
      assert rules[:green].(100, :floor) == %{diff: 0, new: 100, old: 100}
    end

    test "small -50" do
      assert {:ok, rules} = Card.rules("s:-50:r", %{"color" => "yellow"})

      assert rules[:red].(100, :floor) == %{diff: -50, new: 50, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: 40, new: 140, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: 0, new: 100, old: 100}
      assert rules[:green].(100, :floor) == %{diff: 0, new: 100, old: 100}
    end

    test "small -40" do
      assert {:ok, rules} = Card.rules("s:-40:r", %{"color" => "yellow"})

      assert rules[:red].(100, :floor) == %{diff: -40, new: 60, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: 50, new: 150, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: 0, new: 100, old: 100}
      assert rules[:green].(100, :floor) == %{diff: 0, new: 100, old: 100}
    end

    test "small -30" do
      assert {:ok, rules} = Card.rules("s:-30:r", %{"color" => "yellow"})

      assert rules[:red].(100, :floor) == %{diff: -30, new: 70, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: 60, new: 160, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: 0, new: 100, old: 100}
      assert rules[:green].(100, :floor) == %{diff: 0, new: 100, old: 100}
    end

    test "small 30" do
      assert {:ok, rules} = Card.rules("s:30:r", %{"color" => "yellow"})

      assert rules[:red].(100, :floor) == %{diff: 30, new: 130, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: -60, new: 40, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: 0, new: 100, old: 100}
      assert rules[:green].(100, :floor) == %{diff: 0, new: 100, old: 100}
    end

    test "small 40" do
      assert {:ok, rules} = Card.rules("s:40:r", %{"color" => "yellow"})

      assert rules[:red].(100, :floor) == %{diff: 40, new: 140, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: -50, new: 50, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: 0, new: 100, old: 100}
      assert rules[:green].(100, :floor) == %{diff: 0, new: 100, old: 100}
    end

    test "small 50" do
      assert {:ok, rules} = Card.rules("s:50:r", %{"color" => "yellow"})

      assert rules[:red].(100, :floor) == %{diff: 50, new: 150, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: -40, new: 60, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: 0, new: 100, old: 100}
      assert rules[:green].(100, :floor) == %{diff: 0, new: 100, old: 100}
    end

    test "small 60" do
      assert {:ok, rules} = Card.rules("s:60:r", %{"color" => "yellow"})

      assert rules[:red].(100, :floor) == %{diff: 60, new: 160, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: -30, new: 70, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: 0, new: 100, old: 100}
      assert rules[:green].(100, :floor) == %{diff: 0, new: 100, old: 100}
    end

    test "divide" do
      assert {:ok, rules} = Card.rules("d:r", %{"color" => "yellow"})

      assert rules[:red].(100, :floor) == %{diff: -50, new: 50, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: 100, new: 200, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: 0, new: 100, old: 100}
      assert rules[:green].(100, :floor) == %{diff: 0, new: 100, old: 100}
    end

    test "multi" do
      assert {:ok, rules} = Card.rules("m:r", %{"color" => "yellow"})

      assert rules[:red].(100, :floor) == %{diff: 100, new: 200, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: -50, new: 50, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: 0, new: 100, old: 100}
      assert rules[:green].(100, :floor) == %{diff: 0, new: 100, old: 100}
    end

    test "hundred" do
      assert {:ok, rules} = Card.rules("h:1:r", %{"colors" => ["yellow", "blue", "green"]})

      assert rules[:red].(100, :floor) == %{diff: 100, new: 200, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: -10, new: 90, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: -20, new: 80, old: 100}
      assert rules[:green].(100, :floor) == %{diff: -30, new: 70, old: 100}

      assert {:ok, rules} = Card.rules("h:1:r", %{"colors" => ["green", "yellow", "blue"]})

      assert rules[:red].(100, :floor) == %{diff: 100, new: 200, old: 100}
      assert rules[:green].(100, :floor) == %{diff: -10, new: 90, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: -20, new: 80, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: -30, new: 70, old: 100}

      assert {:ok, rules} = Card.rules("h:1:r", %{"colors" => ["blue", "green", "yellow"]})

      assert rules[:red].(100, :floor) == %{diff: 100, new: 200, old: 100}
      assert rules[:blue].(100, :floor) == %{diff: -10, new: 90, old: 100}
      assert rules[:green].(100, :floor) == %{diff: -20, new: 80, old: 100}
      assert rules[:yellow].(100, :floor) == %{diff: -30, new: 70, old: 100}
    end

    test "rounding" do
      assert {:ok, rules} = Card.rules("d:r", %{"color" => "yellow"})

      assert rules[:red].(170, :floor) == %{diff: -90, new: 80, old: 170}
      assert rules[:yellow].(170, :floor) == %{diff: 170, new: 250, old: 170}
      assert rules[:red].(170, :ceil) == %{diff: -80, new: 90, old: 170}
      assert rules[:yellow].(170, :ceil) == %{diff: 170, new: 250, old: 170}

      assert {:ok, rules} = Card.rules("m:r", %{"color" => "yellow"})

      assert rules[:red].(170, :floor) == %{diff: 170, new: 250, old: 170}
      assert rules[:yellow].(170, :floor) == %{diff: -90, new: 80, old: 170}
      assert rules[:red].(170, :ceil) == %{diff: 170, new: 250, old: 170}
      assert rules[:yellow].(170, :ceil) == %{diff: -80, new: 90, old: 170}
    end

    test "clipping" do
      assert {:ok, rules} = Card.rules("s:-50:r", %{"color" => "yellow"})

      assert rules[:red].(30, :floor) == %{diff: -50, new: 10, old: 30}
      assert rules[:yellow].(240, :floor) == %{diff: 40, new: 250, old: 240}

      assert {:ok, rules} = Card.rules("d:r", %{"color" => "yellow"})

      assert rules[:red].(200, :floor) == %{diff: -100, new: 100, old: 200}
      assert rules[:yellow].(200, :floor) == %{diff: 200, new: 250, old: 200}

      assert {:ok, rules} = Card.rules("m:r", %{"color" => "yellow"})

      assert rules[:red].(200, :floor) == %{diff: 200, new: 250, old: 200}
      assert rules[:yellow].(200, :floor) == %{diff: -100, new: 100, old: 200}

      assert {:ok, rules} = Card.rules("h:1:r", %{"colors" => ["blue", "green", "yellow"]})

      assert rules[:red].(200, :floor) == %{diff: 100, new: 250, old: 200}
      assert rules[:blue].(10, :floor) == %{diff: -10, new: 10, old: 10}
      assert rules[:green].(10, :floor) == %{diff: -20, new: 10, old: 10}
      assert rules[:yellow].(10, :floor) == %{diff: -30, new: 10, old: 10}
    end
  end
end
