defmodule Shares.Game.Action.Validator do
  alias Shares.Game
  alias Shares.Game.Card
  alias Shares.Game.Cards
  alias Shares.Game.Player

  @type result :: :ok | {atom(), atom()}
  @type deal_result ::
    :ok
    | {:error, :insufficient_shares}
    | {:error, :negative_quantity}
    | {:error, :insufficient_funds}

  @spec validate_state(Game.t(), atom() | list(atom())) :: :ok | {:error, :wrong_state}
  def validate_state(%Game{state: state}, state),
    do: :ok
  def validate_state(%Game{state: state}, states) when is_list(states),
    do: if(state in states, do: :ok, else: {:error, :wrong_state})
  def validate_state(_, _),
    do: {:error, :wrong_state}

  @spec validate_phase(Game.t(), list(Game.phase())) :: :ok | {:error, :wrong_phase}
  def validate_phase(%Game{stage: {phase, _, _, _}}, phases),
    do: if(phase in phases, do: :ok, else: {:error, :wrong_phase})

  @spec validate_player_turn(Game.t(), Player.id()) :: :ok | {:error, :wrong_player}
  def validate_player_turn(%Game{stage: {_, _, _, index}} = game, id) do
    if(Game.get(game, [:players, index, :id]) == id, do: :ok, else: {:error, :wrong_player})
  end

  @spec validate_joining(Game.t(), Player.id()) :: :ok | {:error, :not_joined}
  def validate_joining(game, id) do
    case Game.get_player(game, id) do
      :error -> {:error, :not_joined}
      _      -> :ok
    end
  end

  @spec validate_no_joining(Game.t(), Player.id()) :: :ok | {:error, :already_joined}
  def validate_no_joining(game, id) do
    case Game.get_player(game, id) do
      :error -> :ok
      _      -> {:error, :already_joined}
    end
  end

  @spec validate_color(atom()) :: :ok | {:error, :wrong_color}
  def validate_color(color),
    do: if(color in Cards.colors(), do: :ok, else: {:error, :wrong_color})

  @spec validate_deal(atom(), Game.t(), atom(), integer()) :: deal_result()
  def validate_deal(:shares, %Game{},  _, value) when value < 0,
    do: {:error, :negative_quantity}
  def validate_deal(:shares, %Game{stage: {_, _, _, index}} = game, color, value) do
    case Game.fetch(game, [:players, index, :shares, color]) do
      {:ok, existing} -> if(existing >= value, do: :ok, else: {:error, :insufficient_shares})
      :error -> {:error, :insufficient_shares}
    end
  end

  def validate_deal(:balance, %Game{}, _, value) when value < 0,
    do: {:error, :negative_quantity}
  def validate_deal(:balance, %Game{stage: {_, _, _, index}} = game, color, value) do
    {:ok, rate} = Game.fetch(game, [:rates, color])
    {:ok, balance} = Game.fetch(game, [:players, index, :balance])

    if(balance >= (rate * value), do: :ok, else: {:error, :insufficient_funds})
  end

  @spec validate_card(Game.t(), Card.id()) :: :ok | {:error, :wrong_card}
  def validate_card(%Game{stage: {_, _, _, index}} = game, card) do
    cards = Game.get(game, [:players, index, :cards])
    if(card in cards, do: :ok, else: {:error, :wrong_card})
  end

  def validate_played_card(_game) do
    :ok
  end
end
