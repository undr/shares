defmodule Shares.Game.Cards do
  # TODO: Move into Card.
  def colors,
    do: ~w[red blue green yellow]a

  @spec all() :: list(String.t())
  def all,
    do: big() ++ small()

  @spec small() :: list(String.t())
  def small do
    Enum.sort(~w[
      s:-60:r s:-50:r s:-40:r s:-30:r s:30:r s:40:r s:50:r s:60:r
      s:-60:g s:-50:g s:-40:g s:-30:g s:30:g s:40:g s:50:g s:60:g
      s:-60:b s:-50:b s:-40:b s:-30:b s:30:b s:40:b s:50:b s:60:b
      s:-60:y s:-50:y s:-40:y s:-30:y s:30:y s:40:y s:50:y s:60:y
    ])
  end

  @spec big() :: list(String.t())
  def big do
    Enum.sort(~w[
      h:1:r h:2:r h:3:r h:1:g h:2:g h:3:g h:1:b h:2:b h:3:b h:1:y h:2:y h:3:y
      m:r m:g m:b m:y
      d:r d:g d:b d:y
    ])
  end
end
