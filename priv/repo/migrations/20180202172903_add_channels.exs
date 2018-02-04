defmodule Evixir.Repo.Migrations.AddChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :channel_id, :string, size: 64
      add :corporation_id, :integer
      add :last_killmail, :integer
    end

    create unique_index(:channels, [:channel_id])
  end
end
