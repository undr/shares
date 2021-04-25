defmodule Shares.Game.Player do
  alias Shares.Utils

  @type id :: Utils.id()
  @type t :: %__MODULE__{
    id: id(),
    name: String.t(),
    shares: %{atom() => integer()},
    balance: integer(),
    cards: list(String.t())
  }

  defstruct [:id, :name, :shares, :balance, :cards]

  @spec total(t(), %{atom() => integer()}) :: integer()
  def total(%__MODULE__{balance: balance} = player, rates) do
    balance + shares_cost(player, rates)
  end

  @spec bankrupt?(t()) :: boolean()
  def bankrupt?(%__MODULE__{balance: balance, shares: shares}) do
    balance == 0 && Enum.all?(shares, fn({_, qty}) -> qty == 0 end)
  end

  defp shares_cost(%__MODULE__{shares: shares}, rates) do
    rates
    |> Stream.map(fn({color, rate}) -> Map.get(shares, color, 0) * rate end)
    |> Enum.sum()
  end
end
