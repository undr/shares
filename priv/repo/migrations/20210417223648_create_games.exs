defmodule Shares.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    Shares.Schema.Types.GameStateEnum.create_type

    create table(:games, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :max_players, :integer, default: 4
      add :timeout, :integer, default: 30
      add :state, :game_state, null: false, default: "waiting"
      add :private, :boolean, null: false, default: false
      add :private_token, :string

      timestamps()
    end

  end
end
