defmodule Shares.Utils do
  @moduledoc false

  @type id :: binary()

  @doc """
  Generates a random binary id.
  """
  @spec random_id() :: id()
  def random_id() do
    :crypto.strong_rand_bytes(20) |> Base.encode32(case: :lower)
  end

  @doc """
  Generates a random short binary id.
  """
  @spec random_short_id() :: id()
  def random_short_id() do
    :crypto.strong_rand_bytes(5) |> Base.encode32(case: :lower)
  end
  
  @doc """
  Convert binary string to atom. It's safe version of `String.to_existing_atom/1`
  """
  @spec to_existing_atom(atom() | String.t()) :: {:ok, atom()} | {:error, :unexistent_atom}
  def to_existing_atom(atom) when is_atom(atom),
    do: atom
  def to_existing_atom(string) when is_binary(string) do
    try do
      {:ok, String.to_existing_atom(string)}
    rescue
      _ in ArgumentError -> {:error, :unexistent_atom}
    end
  end
end
