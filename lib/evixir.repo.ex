defmodule Evixir.Repo do
    use Ecto.Repo,
    otp_app: :evixir
end

defmodule Evixir.ESI.Token do
    use Ecto.Schema

    @primary_key {:channel_id, :string, size: 64}
    schema "esitokens" do
        field :access_token
        field :expires_at, :integer
        field :refresh_token
        field :token_type
    end

    def changeset(token, params \\ %{}) do
        token
        |> Ecto.Changeset.cast(params, [:access_token, :expires_at, :refresh_token, :token_type])
        |> Ecto.Changeset.validate_required([:access_token, :expires_at, :refresh_token, :token_type])
    end
end