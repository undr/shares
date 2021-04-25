defmodule Shares.Game.Server do
  @moduledoc false

  use GenServer, restart: :temporary

  alias Shares.Game

  ## API

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    id = Keyword.fetch!(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: name(id))
  end

  defp name(game_id) do
    {:global, {:game, game_id}}
  end

  @doc """
  Returns game pid given its id.
  """
  @spec get_pid(Game.id()) :: pid() | nil
  def get_pid(game_id) do
    GenServer.whereis(name(game_id))
  end

  @doc """
  Returns basic information about the given game.
  """
  @spec get_summary(Game.id()) :: map()
  def get_summary(game_id) do
    GenServer.call(name(game_id), :get_summary)
  end

  @doc """
  Asynchronously sends a close request to the server.

  This results in saving the file and broadcasting
  a :closed message to the game topic.
  """
  @spec close(Game.id()) :: :ok
  def close(game_id) do
    GenServer.cast(name(game_id), :close)
  end

  ## Callbacks

  @impl true
  def init(opts) do
    id = Keyword.fetch!(opts, :id)
    {:ok, Game.new(id, opts)}
  end

  @impl true
  def handle_call(:get_summary, _from, state) do
    {:reply, summary_from_state(state), state}
  end

  @impl true
  def handle_cast(:close, state) do
    broadcast_message(state.id, :game_closed)
    {:stop, :shutdown, state}
  end

  @impl true
  def terminate(_reason, _state) do
    :ok
  end

  defp summary_from_state(state) do
    Map.take(state, [:id, :name, :opts])
  end

  defp broadcast_error(game_id, error) do
    broadcast_message(game_id, {:error, error})
  end

  defp broadcast_info(game_id, info) do
    broadcast_message(game_id, {:info, info})
  end

  defp broadcast_message(game_id, message) do
    Phoenix.PubSub.broadcast(Shares.PubSub, "games:#{game_id}", message)
  end
end
