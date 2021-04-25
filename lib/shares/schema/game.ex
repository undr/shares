defmodule Shares.Schema.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Shares.Schema.Types.GameStateEnum

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "games" do
    field :name, :string
    field :max_players, :integer, default: 4
    field :timeout, :integer, default: 30
    field :state, GameStateEnum, default: "waiting"
    field :private, :boolean, default: false
    field :private_token, :string

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [])
    |> validate_required([])
  end
end
