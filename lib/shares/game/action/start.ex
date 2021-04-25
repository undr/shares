defmodule Shares.Game.Action.Start do
  alias Shares.Game
  alias Shares.Game.Action.Validator

  @type t :: %__MODULE__{
    index: integer(),
    preloaded: boolean()
  }

  defstruct [:index, preloaded: false]

  use Shares.Game.Action

  @spec handle_preload(t(), Game.t()) :: {:ok, t()}
  def handle_preload(action, %Game{players: players}) do
    {:ok, %{action | index: :rand.uniform(map_size(players)) - 1, preloaded: true}}
  end

  @spec handle_execute(t(), Game.t()) :: {:ok, Game.t()} | {:error, atom()}
  def handle_execute(%__MODULE__{index: index}, game) do
    with :ok <- Validator.validate_state(game, :waiting) do
      {:ok, %{game | stage: {0, 0, 0, index}, state: :playing}}
    end
  end

  # See Game.undo/1 for details
  # def handle_undo(_, game) do
  #   with :ok <- Validator.validate_state(game, :playing) do
  #     {:ok, %{game | stage: {0, 0, 0, nil}, state: :waiting}}
  #   end
  # end
end
