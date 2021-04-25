defmodule Shares.Game.Card.Rules do
  alias Shares.Game.Options

  @type result :: %{
    old: integer(),
    new: integer(),
    diff: integer(),
  }
  @type rule :: (integer(), Options.rounding() -> result())
  @type t :: %{atom() => rule()}

  @spec default(integer(), Options.rounding()) :: result()
  def default(current, _rounding),
    do: %{old: current, new: current, diff: 0}

  @spec divide(integer(), Options.rounding()) :: result()
  def divide(current, rounding) do
    %{old: current, new: trim(current / 2, rounding), diff: round(current / 2, rounding) - current}
  end

  @spec multi(integer(), Options.rounding()) :: result()
  def multi(current, rounding) do
    %{old: current, new: trim(current * 2, rounding), diff: round(current * 2, rounding) - current}
  end

  @spec plus_100(integer(), Options.rounding()) :: result()
  def plus_100(current, rounding) do
    %{old: current, new: trim(current + 100, rounding), diff: 100}
  end

  @spec minus_10(integer(), Options.rounding()) :: result()
  def minus_10(current, rounding) do
    %{old: current, new: trim(current - 10, rounding), diff: -10}
  end

  @spec minus_20(integer(), Options.rounding()) :: result()
  def minus_20(current, rounding) do
    %{old: current, new: trim(current - 20, rounding), diff: -20}
  end

  @spec minus_30(integer(), Options.rounding()) :: result()
  def minus_30(current, rounding) do
    %{old: current, new: trim(current - 30, rounding), diff: -30}
  end

  @spec hundred_i_func(integer()) :: rule()
  def hundred_i_func(index),
    do: Enum.at([&__MODULE__.minus_10/2, &__MODULE__.minus_20/2, &__MODULE__.minus_30/2], index)

  @spec small_func(integer()) :: rule()
  def small_func(amount),
    do: fn(current, rounding) -> %{old: current, new: trim(current + amount, rounding), diff: amount} end

  defp trim(value, rounding) do
    cond do
      value > 250 -> 250
      value < 10  -> 10
      true        -> round(value, rounding)
    end
  end

  defp round(value, algorithm) do
    apply(Kernel, algorithm, [value / 10]) * 10
  end
end
