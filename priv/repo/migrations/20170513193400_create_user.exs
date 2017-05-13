defmodule Tracker2x2.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :tracker_token, :binary 
      add :encryption_version, :binary

      timestamps()
    end

    create unique_index(:users, [:email])
    create index(:users, [:encryption_version])

  end
end
