defmodule Shares.Game.Options do
  @type rounding :: :floor | :ceil
  @type t :: %__MODULE__{
    min_players: pos_integer(),
    max_players: pos_integer(),
    cards: {integer(), integer()},
    rounding: rounding(),
    timeout: pos_integer(),
    stage_timeout: pos_integer()
  }

  defstruct [min_players: 2, max_players: 5, cards: {3, 5}, rounding: :floor, timeout: 600, stage_timeout: 60]

  @spec init(map() | keyword()) :: t()
  def init(opts) do
    struct(__MODULE__, opts)
  end
end
