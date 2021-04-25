defmodule Shares.Game.Action.Buy do
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
         :ok <- Validator.validate_deal(:balance, game, color, qty) do
      buy(game, color, qty)
    else
      {:error, :unexistent_atom} ->
        {:error, :wrong_color}

      error ->
        error
    end
  end

  # See Game.undo/1 for details
  # def handle_undo(%{player: id, color: color, quantity: qty}, %Game{state: :playing} = game) do
  #   Action.execute(%Action.Sell{player: id, color: color, quantity: qty, preloaded: true}, game)
  # end

  defp buy(%Game{stage: {_, _, _, index}} = game, color, qty) do
    {:ok, rate} = Game.fetch(game, [:rates, color])
    {:ok, balance} = Game.fetch(game, [:players, index, :balance])

    new_balance = balance - (rate * qty)
    new_balance = if(new_balance >= 0, do: new_balance, else: raise("negative balance"))

    game = game
    |> Game.update([:players, index, :shares, color], &(&1 + qty))
    |> Game.put([:players, index, :balance], new_balance)

    {:ok, game}
  end
end
