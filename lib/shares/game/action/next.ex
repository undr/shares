defmodule Shares.Game.Action.Next do
  alias Shares.Game
  alias Shares.Game.Stage
  alias Shares.Game.Action.Validator

  @type t :: %__MODULE__{
    preloaded: boolean()
  }

  defstruct [preloaded: false]

  use Shares.Game.Action

  @spec handle_preload(t(), Game.t()) :: {:ok, t()}
  def handle_preload(action, _game) do
    {:ok, %{action | preloaded: true}}
  end

  @spec handle_execute(t(), Game.t()) :: {:ok, Game.t()} | {:error, atom()}
  def handle_execute(_, game) do
    with :ok <- Validator.validate_state(game, [:finale, :playing]),
         :ok <- Validator.validate_played_card(game) do
      case Stage.next(game) do
        :phase   -> next_phase(game)
        :turn    -> next_turn(game)
        :round   -> next_round(game)
        :finale  -> finale(game)
        :done    -> done(game)
        :unknown -> {:error, :undefined_stage}
      end
    end
  end

  # See Game.undo/1 for details
  # def handle_undo(_, %Game{} = game) do
  #   with :ok <- Validator.validate_state(game, [:finale, :playing]) do
  #     case Stage.prev(game) do
  #       :phase   -> prev_phase(game)
  #       :turn    -> prev_turn(game)
  #       :round   -> prev_round(game)
  #       :playing -> playing(game)
  #       :start   -> {:error, :start_point}
  #       :unknown -> {:error, :undefined_stage}
  #     end
  #   end
  # end

  defp next_phase(%Game{stage: stage} = game),
    do: {:ok, %{game | stage: put_elem(stage, 0, elem(stage, 0) + 1)}}

  defp next_turn(%Game{stage: {_, turn, round, index}, players: players, state: :playing} = game),
    do: {:ok, %{game | stage: {0, turn + 1, round, next_player(players, index)}}}
  defp next_turn(%Game{stage: {_, turn, round, index}, players: players, state: :finale} = game),
    do: {:ok, %{game | stage: {1, turn + 1, round, next_player(players, index)}}}

  defp next_round(%Game{stage: {_, _, round, index}, players: players} = game),
    do: {:ok, %{game | stage: {0, 0, round + 1, next_player(players, index)}}}

  defp finale(%Game{stage: {_, _, round, index}, players: players} = game),
    do: {:ok, %{game | stage: {1, 0, round + 1, next_player(players, index)}, state: :finale}}

  defp done(%Game{state: :finale} = game),
    do: {:ok, game |> Game.set_winners() |> Map.put(:Lstate, :done)}

  # defp prev_phase(%Game{stage: stage} = game),
  #   do: {:ok, %{game | stage: put_elem(stage, 0, elem(stage, 0) - 1)}}
  #
  # defp prev_turn(%Game{stage: {_, turn, round, index}, players: players, state: :playing} = game),
  #   do: {:ok, %{game | stage: {2, turn - 1, round, prev_player(players, index)}}}
  # defp prev_turn(%Game{stage: {_, turn, round, index}, players: players, state: :finale} = game),
  #   do: {:ok, %{game | stage: {1, turn - 1, round, prev_player(players, index)}}}
  #
  # defp prev_round(%Game{stage: {_, _, round, index}, players: players} = game),
  #   do: {:ok, %{game | stage: {0, map_size(players) - 1, round - 1, prev_player(players, index)}}}
  #
  # defp playing(%Game{stage: {_, _, round, index}, players: players} = game),
  #   do: {:ok, %{game | stage: {2, map_size(players) - 1, round - 1, prev_player(players, index)}, state: :playing}}

  defp next_player(players, index) do
    index = index + 1
    if((index) < map_size(players), do: index, else: 0)
  end

  # defp prev_player(players, index) do
  #   index = index - 1
  #   if((index) < 0, do: index, else: map_size(players))
  # end
end
