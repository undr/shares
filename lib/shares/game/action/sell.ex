defmodule Shares.Game.Action.Sell do
  alias Shares.Game
  alias Shares.Utils
  alias Shares.Game.Player
  alias Shares.Game.Action.Validator

  @type t :: %__MODULE__{
    player: Player.id(),
    color: atom(),
    quantity: integer(),
    preloaded: boolean()
  }

  defstruct [:player, :color, quantity: 0, preloaded: false]

  use Shares.Game.Action

  @spec handle_preload(t(), Game.t()) :: {:ok, t()}
  def handle_preload(action, _game) do
    {:ok, %{action | preloaded: true}}
  end

  @spec handle_execute(t(), Game.t()) :: {:ok, Game.t()} | {:error, atom()}
  def handle_execute(%{player: player, color: color, quantity: qty}, game) do
    with {:ok, color} <- Utils.to_existing_atom(color),
         :ok <- Validator.validate_state(game, :playing),
         :ok <- Validator.validate_phase(game, [0, 2]),
         :ok <- Validator.validate_player_turn(game, player),
         :ok <- Validator.validate_color(color),
         :ok <- Validator.validate_deal(:shares, game, color, qty) do
      sell(game, color, qty)
    else
      {:error, :unexistent_atom} ->
        {:error, :wrong_color}

      error ->
        error
    end
  end

  # See Game.undo/1 for details
  # def handle_undo(%{player: id, color: color, quantity: qty}, %Game{state: :playing} = game) do
  #   Action.execute(%Action.Buy{player: id, color: color, quantity: qty, preloaded: true}, game)
  # end

  defp sell(%Game{stage: {_, _, _, index}} = game, color, qty) do
    {:ok, rate} = Game.fetch(game, [:rates, color])
    {:ok, existing} = Game.fetch(game, [:players, index, :shares, color])

    new_qty = existing - qty
    new_qty = if(new_qty >= 0, do: new_qty, else: raise("negative number of shares"))

    game = game
    |> Game.put([:players, index, :shares, color], new_qty)
    |> Game.update([:players, index, :balance], &(&1 + (rate * qty)))

    {:ok, game}
  end
end
