defmodule Shares.Game.Action.Card do
  alias Shares.Game
  alias Shares.Game.Card, as: GameCard
  alias Shares.Game.Player
  alias Shares.Game.Action.Validator

  @type t :: %__MODULE__{
    player: Player.id(),
    card: GameCard.id(),
    payload: map(),
    preloaded: boolean()
  }

  defstruct [:player, :card, :payload, preloaded: false]

  use Shares.Game.Action

  @spec handle_preload(t(), Game.t()) :: {:ok, t()}
  def handle_preload(action, _game) do
    {:ok, %{action | preloaded: true}}
  end

  @spec handle_execute(t(), Game.t()) :: {:ok, Game.t()} | {:error, atom()}
  def handle_execute(%{player: player, card: card, payload: payload}, game) do
    with :ok <- Validator.validate_state(game, [:playing, :finale]),
         :ok <- Validator.validate_phase(game, [1]),
         :ok <- Validator.validate_player_turn(game, player),
         {:ok, rules} <- GameCard.rules(card, payload) do
      apply_rules(game, rules)
    end
  end

  defp apply_rules(game, rules) do
    changes = rules
    |> Stream.map(fn({color, func}) -> {color, func.(Game.get(game, [:rates, color]), game.opts.rounding)} end)
    |> Enum.into(%{})

    game = game
    |> update_rates(changes)
    |> update_players(changes)

    {:ok, game}
  end

  defp update_rates(game, changes) do
    Enum.reduce(changes, game, fn({color, change}, memo) ->
      Game.put(memo, [:rates, color], change.new)
    end)
  end

  defp update_players(%{players: players, stage: {_, _, _, current}} = game, changes) do
    players = players
    |> Stream.with_index()
    |> Stream.map(fn({{id, player}, index}) -> {id, update_player(player, changes, index == current)} end)
    # Remove bankrupts after the round finished.
    # |> Stream.reject(fn({_, player}) -> Player.bankrupt?(player) end)
    |> Enum.into(%{})

    %{game | players: players}
  end

  # Current player
  defp update_player(player, changes, true) do
    increment = changes
    |> Enum.map(fn({color, change}) ->
      shares = player.shares[color]

      cond do
        no_change?(change) ->
          0

        rise_above_limit?(change) ->
          rise_compensation(shares, change)

        drop_below_limit?(change) ->
          drop_compensation(shares, change)

        true ->
          compensation(shares, change)
      end
    end)
    |> Enum.sum()

    %{player | balance: player.balance + increment}
  end

  # Others
  defp update_player(player, changes, false) do
    changes
    |> Enum.sort_by(fn({_, change}) -> change.diff end, :desc)
    |> Enum.reduce(player, fn({color, change}, memo) ->
      shares = memo.shares[color]

      cond do
        rise_above_limit?(change) ->
          increment = rise_compensation(shares, change)
          apply_increment(memo, color, increment, change)

        drop_below_limit?(change) ->
          increment = fine(shares, change)
          apply_increment(memo, color, increment, change)

        true ->
          memo
      end
    end)
  end

  defp apply_increment(player, color, increment, change) do
    new_balance = increment + player.balance

    if new_balance < 0 do
      {shares, new_balance} = cover_shortage(player.shares[color], abs(new_balance), change)
      %{player | balance: new_balance, shares: Map.put(player.shares, color, shares)}
    else
      %{player | balance: new_balance}
    end
  end

  defp cover_shortage(shares, shortage, change) do
    for_sale = ceil(shortage / change.new)
    income = for_sale * change.new
    shares = shares - for_sale

    if shares > 0 do
      {shares, income - shortage}
    else
      {0, 0}
    end
  end

  defp rise_above_limit?(change) do
    change.old + change.diff > 250
  end

  defp drop_below_limit?(change) do
    change.old + change.diff < 10
  end

  defp no_change?(change) do
    change.diff == 0
  end

  defp rise_compensation(shares, change) do
    shares * (change.old + change.diff - 250)
  end

  defp drop_compensation(shares, change) do
    shares * (change.old - 10)
  end

  defp compensation(shares, change) do
    if(change.diff < 0, do: shares * abs(change.diff), else: 0)
  end

  def fine(shares, change) do
    -(shares * (abs(change.diff) + 10 - change.old))
  end
end
