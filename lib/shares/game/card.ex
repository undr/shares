defmodule Shares.Game.Card do
  alias Shares.Game.Cards
  alias Shares.Game.Card.Rules
  alias Shares.Utils

  @type id :: String.t()
  @type amount :: integer()
  @type type :: :small | :hundred | :multi | :divide
  @type t :: %__MODULE__{
    id: id(),
    amount: amount(),
    color: atom(),
    type: type()
  }

  defstruct [:id, :amount, :color, :type]

  @colors %{"r" => :red, "g" => :green, "b" => :blue, "y" => :yellow}
  @s_regex ~r/(?<amount>(\-)?\d+):(?<color>r|b|g|y)/
  @h_regex ~r/(1|2|3):(?<color>r|b|g|y)/
  @m_regex ~r/(?<color>r|b|g|y)/
  @d_regex ~r/(?<color>r|b|g|y)/

  @spec parse(id()) :: {:ok, t()} | {:error, :invalid}
  def parse("s:" <> command = id) do
    case Regex.named_captures(@s_regex, command) do
      %{"amount" => amount, "color" => color} ->
        {:ok, %__MODULE__{id: id, amount: cast_amount(amount), color: cast_color(color), type: :small}}

      nil ->
        {:error, :invalid}
    end
  end

  def parse("h:" <> command = id) do
    case Regex.named_captures(@h_regex, command) do
      %{"color" => color} ->
        {:ok, %__MODULE__{id: id, color: cast_color(color), type: :hundred}}

      nil ->
        {:error, :invalid}
    end
  end

  def parse("m:" <> command = id) do
    case Regex.named_captures(@m_regex, command) do
      %{"color" => color} ->
        {:ok, %__MODULE__{id: id, color: cast_color(color), type: :multi}}

      nil ->
        {:error, :invalid}
    end
  end

  def parse("d:" <> command = id) do
    case Regex.named_captures(@d_regex, command) do
      %{"color" => color} ->
        {:ok, %__MODULE__{id: id, color: cast_color(color), type: :divide}}

      nil ->
        {:error, :invalid}
    end
  end

  def parse(_), do:
    {:error, :invalid}

  @spec rules(id() | t(), map()) :: {:ok, Rules.t()} | {:error, :invalid_payload}
  def rules(card_id, payload) when is_binary(card_id) do
    case parse(card_id) do
      {:ok, card} -> rules(card, payload)
      error       -> error
    end
  end

  def rules(%__MODULE__{type: :small} = card, %{"color" => alt_color}) do
    alt_amount = if(card.amount < 0, do: (90 - abs(card.amount)), else: -(90 - abs(card.amount)))

    {:ok, alt_color} = Utils.to_existing_atom(alt_color)

    rules = Enum.reduce(Cards.colors(), %{}, fn(color, memo) ->
      cond do
        color == card.color -> Map.put(memo, color, Rules.small_func(card.amount))
        color == alt_color  -> Map.put(memo, color, Rules.small_func(alt_amount))
        true                -> Map.put(memo, color, &Rules.default/2)
      end
    end)

    {:ok, rules}
  end

  def rules(%__MODULE__{type: :hundred} = card, %{"colors" => colors}) do
    rules = colors
    |> Stream.map(fn(color) ->
      {:ok, color} = Utils.to_existing_atom(color)
      color
    end)
    |> Stream.with_index()
    |> Enum.reduce(%{card.color => &Rules.plus_100/2}, fn({color, index}, memo) ->
      Map.put(memo, color, Rules.hundred_i_func(index))
    end)

    {:ok, rules}
  end

  def rules(%__MODULE__{type: type} = card, %{"color" => alt_color}) when type in [:divide, :multi] do
    {:ok, alt_color} = Utils.to_existing_atom(alt_color)

    func = if(type == :divide, do: &Rules.divide/2, else: &Rules.multi/2)
    alt_func = if(type == :divide, do: &Rules.multi/2, else: &Rules.divide/2)

    rules = Enum.reduce(Cards.colors(), %{}, fn(color, memo) ->
      cond do
        color == card.color -> Map.put(memo, color, func)
        color == alt_color  -> Map.put(memo, color, alt_func)
        true                -> Map.put(memo, color, &Rules.default/2)
      end
    end)

    {:ok, rules}
  end

  def rules(_, _),
    do: {:error, :invalid_payload}

  defp cast_color(color),
    do: Map.get(@colors, color)

  defp cast_amount(amount),
    do: String.to_integer(amount)
end
