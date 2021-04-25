defmodule Shares.Game.Supervisor do
  @moduledoc false

  use DynamicSupervisor

  alias Shares.Game
  alias Shares.Utils
  alias Shares.Game.Server, as: GameServer

  @name __MODULE__

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: @name)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec create_game(keyword()) :: {:ok, Game.id()} | {:error, any()}
  def create_game(opts \\ []) do
    id = Utils.random_id()
    opts = Keyword.put(opts, :id, id)

    case DynamicSupervisor.start_child(@name, {GameServer, opts}) do
      {:ok, _} ->
        broadcast_games_message({:game_created, id})
        {:ok, id}

      {:ok, _, _} ->
        broadcast_games_message({:game_created, id})
        {:ok, id}

      :ignore ->
        {:error, :ignore}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec close_game(Game.id()) :: :ok
  def close_game(id) do
    GameServer.close(id)
    broadcast_games_message({:game_closed, id})
    :ok
  end

  defp broadcast_games_message(message) do
    Phoenix.PubSub.broadcast(Shares.PubSub, "games", message)
  end

  @doc """
  Returns ids of all the running game processes.
  """
  @spec get_game_ids() :: list(Game.id())
  def get_game_ids() do
    :global.registered_names()
    |> Enum.flat_map(fn
      {:game, id} -> [id]
      _ -> []
    end)
  end

  @doc """
  Returns summaries of all the running game processes.
  """
  @spec get_game_summaries() :: list()
  def get_game_summaries() do
    Enum.map(get_game_ids(), &GameServer.get_summary/1)
  end

  @doc """
  Checks if a game process with the given id exists.
  """
  @spec game_exists?(Game.id()) :: boolean()
  def game_exists?(id) do
    :global.whereis_name({:game, id}) != :undefined
  end

  @doc """
  Retrieves pid of a game process identified by the given id.
  """
  @spec get_game_pid(Game.id()) :: {:ok, pid()} | {:error, :nonexistent}
  def get_game_pid(id) do
    case :global.whereis_name({:game, id}) do
      :undefined -> {:error, :nonexistent}
      pid -> {:ok, pid}
    end
  end
end
