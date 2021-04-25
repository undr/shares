defmodule Shares.Game.Stage do
  alias Shares.Game

  @spec next(Game.t()) :: :phase | :turn | :round | :finale | :done | :unknown
  def next(%Game{stage: {phase, turn, _, _}, players: players, state: :playing} = game) do
    if phase == 2 do
      if turn == map_size(players) - 1 do
        if(next_finale_round?(game), do: :finale, else: :round)
      else
        :turn
      end
    else
      :phase
    end
  end
  def next(%Game{stage: {_, turn, _, _}, players: players, state: :finale}),
    do: if(turn == map_size(players) - 1, do: :done, else: :finale_turn)
  def next(_),
    do: :unknown

  # See Game.undo/1 for details
  # def prev(%Game{stage: {_, _, 0, _}, state: :playing}),
  #   do: :start
  # def prev(%Game{stage: {phase, turn, _, _}, state: :playing}) do
  #   if phase == 0 do
  #     if(turn == 0, do: :round, else: :turn)
  #   else
  #     :phase
  #   end
  # end
  #
  # def prev(%Game{stage: {phase, turn, _, _}, state: :finale}) do
  #   if phase == 0 do
  #     if(turn == 0, do: :playing, else: :turn)
  #   else
  #     :phase
  #   end
  # end
  #
  # def prev(_),
  #   do: :unknown

  # defp next_finale_round?(%Game{players: [player|_]}),
  #   do: length(player.cards) == 1

  defp next_finale_round?(%Game{players: players}),
    do: Enum.all?(players, fn(player) -> length(player.cards) == 1 end)
end
