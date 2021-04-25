defmodule Shares.Game.Action.Join do
  alias Shares.Game
  alias Shares.Game.Player
  alias Shares.Game.Action.Validator

  @type t :: %__MODULE__{
    id: Player.id(),
    name: String.t(),
    shares: map(),
    b_cards: list(),
    s_cards: list(),
    preloaded: boolean()
  }

  defstruct [:id, :name, :shares, :b_cards, :s_cards, preloaded: false]

  use Shares.Game.Action

  @spec handle_preload(t(), Game.t()) :: {:ok, t()}
  def handle_preload(action, %Game{b_cards: game_b_cards, s_cards: game_s_cards, opts: opts}) do
    with {b_num, s_num} <- opts.cards,
         b_cards <- Enum.take_random(game_b_cards, b_num),
         s_cards <- Enum.take_random(game_s_cards, s_num) do
      {:ok, %{action | shares: shares(), b_cards: b_cards, s_cards: s_cards, preloaded: true}}
    else
      _ -> :ignore
    end
  end

  @spec handle_execute(t(), Game.t()) :: {:ok, Game.t()} | {:error, atom()}
  def handle_execute(%{id: id, name: name, b_cards: b_cards, s_cards: s_cards, shares: shares}, game) do
    player = %Player{id: id, name: name, cards: b_cards ++ s_cards, shares: shares, balance: 0}

    with :ok <- Validator.validate_state(game, :waiting),
         :ok <- Validator.validate_no_joining(game, id),
         {:ok, game} <- update_execute(game, :players, player),
         {:ok, game} <- update_execute(game, :b_cards, b_cards),
         {:ok, game} <- update_execute(game, :s_cards, s_cards) do
      {:ok, game}
    end
  end

  # See Game.undo/1 for details
  # def handle_undo(%{id: id, b_cards: b_cards, s_cards: s_cards}, game) do
  #   with Validator.validate_state(game, :waiting),
  #        :ok <- Validator.validate_joining(game, id),
  #        {:ok, game} <- update_undo(game, :players, id),
  #        {:ok, game} <- update_undo(game, :b_cards, b_cards),
  #        {:ok, game} <- update_undo(game, :s_cards, s_cards) do
  #     {:ok, game}
  #   end
  # end

  defp update_execute(%{players: players} = game, :players, player) when map_size(players) == 0,
    do: {:ok, %{game | players: %{player.id => player}, owner: player.id}}
  defp update_execute(game, :players, player),
    do: {:ok, Game.put(game, [:players, player.id], player)}
  defp update_execute(%{b_cards: game_cards} = game, :b_cards, player_cards),
    do: {:ok, %{game | b_cards: game_cards -- player_cards}}
  defp update_execute(%{s_cards: game_cards} = game, :s_cards, player_cards),
    do: {:ok, %{game | s_cards: game_cards -- player_cards}}

  # defp update_undo(%{players: players} = game, :players, _player) when map_size(players) == 1,
  #   do: {:ok, %{game | players: %{}, owner: nil}}
  # defp update_undo(%{players: players} = game, :players, player),
  #   do: {:ok, %{game | players: Map.delete(players, player)}}
  # defp update_undo(%{b_cards: game_cards} = game, :b_cards, player_cards),
  #   do: {:ok, %{game | b_cards: union_cards(game_cards, player_cards)}}
  # defp update_undo(%{s_cards: game_cards} = game, :s_cards, player_cards),
  #   do: {:ok, %{game | s_cards: union_cards(game_cards, player_cards)}}
  #
  # defp union_cards(coll1, coll2) do
  #   (coll1 ++ coll2)
  #   |> Enum.uniq()
  #   |> Enum.sort()
  # end

  defp shares do
    %{red: 1, green: 1, blue: 1, yellow: 1}
  end
end
