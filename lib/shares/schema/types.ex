defmodule Shares.Schema.Types do
  import EctoEnum

  defenum GameStateEnum, :game_state, [:waiting, :playing, :finale, :done]
end
