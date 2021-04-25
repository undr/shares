defmodule Shares.Game.Action do
  # List of available actions:
  # join: %{id: '2qedejwl', shares: %{red: 1, green: 1, blue: 1, yellow: 1}, cards: [1,2,3,4,5,6,7,8], owner: false}
  # start: %{player: '2qedejwl'}
  # sell: %{red: 1, blue: 1}
  # buy: %{green: 2}
  # next: %{}
  # card: %{id: 1, red: 100, yellow: -10, green: -20, blue: -30}
  # next: %{}
  # sell: %{red: 1, blue: 1}
  # buy: %{green: 2}
  # next: %{}
  # leave: %{player: '2qedejwl'}
  # kick: %{reason: "This is the private room"}

  alias Shares.Game
  alias Shares.Game.Action

  @type t ::
    Action.Buy.t()
    | Action.Card.t()
    | Action.Join.t()
    | Action.Next.t()
    | Action.Sell.t()
    | Action.Start.t()


  defmacro __using__(_opts \\ []) do
    quote location: :keep do
      def preload(%__MODULE__{preloaded: true} = action, %Shares.Game{}),
        do: {:ok, action}
      def preload(%__MODULE__{} = action, %Shares.Game{} = game),
        do: handle_preload(action, game)
      def preload(_, _),
        do: :ignore

      def execute(%__MODULE__{preloaded: true} = action, %Shares.Game{} = game),
        do: handle_execute(action, game)
      def execute(_, _),
        do: :ignore

      # # See Game.undo/1 for details
      # def undo(%__MODULE__{preloaded: true} = action, %Shares.Game{} = game),
      #   do: handle_undo(action, game)
      # def undo(_, _),
      #   do: :ignore

      def handle_preload(_, _),
        do: :ignore

      def handle_execute(_, _),
        do: :ignore

      # See Game.undo/1 for details
      # def handle_undo(_, _),
      #   do: :ignore

      defoverridable [handle_preload: 2, handle_execute: 2]

      defimpl Shares.Game.Action.Protocol do
        def preload(action, game),
          do: __impl__(:for).preload(action, game)

        def execute(action, game),
          do: __impl__(:for).execute(action, game)

        def undo(action, game),
          do: __impl__(:for).undo(action, game)
      end
    end
  end

  @spec create(map()) :: {:ok, t()} | {:error, :unsupported_action}
  def create(%{"type" => "join"} = action),
    do: {:ok, struct(Action.Join, payload(action))}
  def create(%{"type" => "start"} = action),
    do: {:ok, struct(Action.Start, payload(action))}
  def create(%{"type" => "sell"} = action),
    do: {:ok, struct(Action.Sell, payload(action))}
  def create(%{"type" => "buy"} = action),
    do: {:ok, struct(Action.Buy, payload(action))}
  def create(%{"type" => "next"} = action),
    do: {:ok, struct(Action.Next, payload(action))}
  def create(%{"type" => "card"} = action),
    do: {:ok, struct(Action.Card, payload(action))}
  def create(_),
    do: {:error, :unsupported_action}

  @spec preload(t(), Game.t()) :: {:ok, t()} | {:error, atom()}
  def preload(action, game) do
    Action.Protocol.preload(action, game)
  end

  @spec execute(t(), Game.t()) :: {:ok, Game.t()} | {:error, atom()}
  def execute(action, game) do
    Action.Protocol.execute(action, game)
  end

  # See Game.undo/1 for details
  # def undo(action, game) do
  #   Action.Protocol.undo(action, game)
  # end

  defp payload(action) do
    action
    |> symbolize_keys()
    |> Map.delete(:preloaded)
  end

  defp symbolize_keys(action) do
    for {key, val} <- action, into: %{}, do: {String.to_existing_atom(key), val}
  end
end
