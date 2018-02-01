defmodule Evixir.Repo.Migrations.AddTokenTable do
  use Ecto.Migration

  def change do
    create table(:esitokens, primary_key: false) do
      add :channel_id, :string, size: 64, primary_key: true
      add :access_token, :string
      add :expires_at, :integer
      add :refresh_token, :string
      add :token_type, :string
    end
  end
end
