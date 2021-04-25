defmodule Shares.Game do
  alias Shares.Utils
  alias Shares.Game.Cards
  alias Shares.Game.Action
  alias Shares.Game.Options
  alias Shares.Game.Player

  @type id :: Utils.id()
  @type rates :: %{atom() => non_neg_integer()}
  @type players :: %{id() => Player.t()}
  @type actions :: list(Action.t())
  @type phase :: 0..2
  @type turn :: non_neg_integer()
  @type round :: non_neg_integer()
  @type index :: non_neg_integer()
  @type state :: :waiting | :playing | :finale | :done
  @type stage :: {phase(), turn(), round(), nil | index()}
  @type t :: %__MODULE__{
    id: id(),
    rates: rates(),
    actions: actions(),
    players: players(),
    b_cards: list(String.t()),
    s_cards: list(String.t()),
    owner: nil | Player.id(),
    winners: list({Player.id(), integer()}),
    stage: stage(),
    opts: Options.t(),
    state: state()
  }

  defstruct [
    :id,
    :rates,
    actions: [],
    players: %{},
    b_cards: [],
    s_cards: [],
    owner: nil,
    winners: [],
    stage: {0, 0, 0, nil},
    opts: %Options{},
    state: :waiting
  ]

  @spec new(id(), Keyword.t() | map()) :: t()
  def new(id, opts \\ %{}) do
    %__MODULE__{
      id: id,
      rates: rates(),
      b_cards: big_cards(),
      s_cards: small_cards(),
      opts: Options.init(opts)
    }
  end

  @spec execute(t(), Action.t()) :: {:ok, t()} | {:error, atom()} | :ignore
  def execute(%__MODULE__{} = game, action) do
    with {:ok, action} <- Action.create(action),
         {:ok, action} <- Action.preload(action, game),
         {:ok, game} <- redo(game, action) do
      {:ok, game}
    end
  end

  @spec redo(t(), Action.t()) :: {:ok, t()} | {:error, atom()} | :ignore
  def redo(%__MODULE__{} = game, action) do
    with {:ok, game} <- Action.execute(action, game),
         {:ok, game} <- push_action(game, action) do
      {:ok, game}
    end
  end

  # Unfortunately some of actions are irreversible (leave, card),
  # so we cannot walk through the game in a backward direction.
  # I'll comment out these lines for the moment when
  # I will learn how to implement full reversability of actions.
  # def undo(%__MODULE__{} = game) do
  #   with {:ok, game, action} <- pop_action(game),
  #        {:ok, game} <- Action.undo(action, game) do
  #     {:ok, game}
  #   else
  #     :empty -> :ok
  #     error -> error
  #   end
  # end

  @spec push_action(t(), Action.t()) :: {:ok, t()}
  def push_action(%__MODULE__{actions: actions} = game, action),
    do: {:ok, %{game | actions: [action | actions]}}

  @spec pop_action(t()) :: :empty | {:ok, t(), Action.t()}
  def pop_action(%__MODULE__{actions: []}),
    do: :empty
  def pop_action(%__MODULE__{actions: [action | actions]} = game),
    do: {:ok, %{game | actions: actions}, action}

  @spec fetch(t(), list()) :: :error | {:ok, term()}
  def fetch(%__MODULE__{} = game, path),
    do: get_in(game, Enum.map(path, &(key(&1)))) |> wrap_nil()

  @spec get(t(), list()) :: term()
  def get(%__MODULE__{} = game, path),
    do: get_in(game, Enum.map(path, &(key(&1))))

  @spec put(t(), list(), term()) :: t()
  def put(%__MODULE__{} = game, path, value),
    do: put_in(game, Enum.map(path, &(key(&1))), value)

  @spec update(t(), list(), fun()) :: t()
  def update(%__MODULE__{} = game, path, fun),
    do: update_in(game, Enum.map(path, &(key(&1))), fun)

  @spec get_player(t(), index() | id()) :: :error | {:ok, Player.t()}
  def get_player(%__MODULE__{} = game, id_or_index),
    do: fetch(game, [:players, id_or_index])

  @spec set_winners(t()) :: t()
  def set_winners(game) do
    %{game | winners: winners(game)}
  end

  defp winners(%__MODULE__{players: players, rates: rates}) do
    players
    |> Stream.map(fn({id, player}) -> {id, Player.total(player, rates)} end)
    |> Enum.sort_by(&(elem(&1, 1)), :desc)
  end

  defp rates do
    %{blue: 100, green: 100, yellow: 100, red: 100}
  end

  defp big_cards,
    do: Cards.big()

  defp small_cards,
    do: Cards.small()

  defp wrap_nil(nil),
    do: :error
  defp wrap_nil(value),
    do: {:ok, value}

  # Access to nested maps by index instead of key.
  defp key(key, default \\ nil)
  defp key(key, default) when is_integer(key) do
    fn
      :get, data, next ->
        {_, value} = Enum.at(data, key, default)
        next.(value)

      :get_and_update, data, next ->
        {mapkey, value} = Enum.at(data, key, default)

        case next.(value) do
          {get, update} -> {get, Map.put(data, mapkey, update)}
          :pop -> {value, Map.delete(data, mapkey)}
        end
    end
  end

  # Access to nonexistent indexes and keys. Suspect it violates the "let it crash" principle.
  # Need to clarify this point later.
  # defp key(key, default) when is_integer(key) do
  #   fn
  #     :get, data, next ->
  #       case Enum.at(data, key, default) do
  #         nil -> nil
  #         {_, value} -> next.(value)
  #       end
  #
  #     :get_and_update, data, next ->
  #       case Enum.at(data, key, default) do
  #         nil ->
  #           {nil, data}
  #
  #         {mapkey, value} ->
  #           case next.(value) do
  #             {get, update} -> {get, Map.put(data, mapkey, update)}
  #             :pop -> {value, Map.delete(data, mapkey)}
  #           end
  #       end
  #   end
  # end

  defp key(key, default) do
    fn
      :get, data, next ->
        next.(Map.get(data, key, default))

      :get_and_update, data, next ->
        value = Map.get(data, key, default)

        case next.(value) do
          {get, update} -> {get, Map.put(data, key, update)}
          :pop -> {value, Map.delete(data, key)}
        end
    end
  end
end
