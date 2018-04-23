defmodule Evixir.ESI.Authentication do
    use OAuth2.Strategy
    require Ecto.Query

    def client do
        OAuth2.Client.new([
            client_id: Application.get_env(:oauth2, :client_id),
            client_secret: Application.get_env(:oauth2, :client_secret),
            redirect_uri: Application.get_env(:oauth2, :redirect_uri),
            site: "https://login.eveonline.com"
          ])
    end

    def auth(params) do
        OAuth2.Client.authorize_url!(client, [scope: "esi-killmails.read_corporation_killmails.v1", state: params["channel"]])
    end

    def auth_header do
        "Basic " <> Base.encode64(Application.get_env(:oauth2, :client_id) <> ":" <> Application.get_env(:oauth2, :client_secret))
    end

    def callback(params) do
        OAuth2.Client.get_token(client, [code: params["code"], grant_type: "authorization_code"], [{"Authorization", auth_header()}]) |> handle_callback(params["state"])
    end

    def handle_callback({:ok, data}, state) do
        Evixir.ESI.Token |> Ecto.Query.where(channel_id: ^state) |> Evixir.Repo.one |> handle_auth_token(data, state)
    end

    def handle_auth_token(nil, new_token, channelid) do
        char_data = HTTPotion.get("https://login.eveonline.com/oauth/verify", headers: ["Authorization": "Bearer " <> new_token.token.access_token, "User-Agent": "Evixir"]).body |> Poison.decode!
        corp_id = get_corp_id(char_data["CharacterID"])

        new_auth_token = %Evixir.ESI.Token{
            channel_id: channelid,
            access_token: new_token.token.access_token,
            expires_at: new_token.token.expires_at,
            refresh_token: new_token.token.refresh_token,
            token_type: new_token.token.token_type,
            channel: create_channel_object(channelid, corp_id, new_token.token)
        }
        Evixir.Repo.insert(new_auth_token) |> handle_new_token
    end

    def handle_auth_token(existing_token, new_token, channelid) do
        handle_refresh({:ok, new_token}, existing_token)
        "Tokens refreshed"
    end

    def create_channel_object(channel_id, corp_id, token) do
        recent_km = Evixir.ESI.Killmail.get_recent_killmails(corp_id, token)
        %Evixir.ESI.Channel{
            channel_id: channel_id,
            corporation_id: corp_id,
            last_killmail: hd(recent_km)["killmail_id"]
        }
    end

    def handle_new_token({:ok, token}) do
        "Your are authenticated. You may close this page now."
    end

    defp get_corp_id(character_id) do
        Evixir.ESI.Character.get_character_info(character_id)["corporation_id"]
    end

    def handle_new_token({:error, reason}) do
        "Something went wrong! :("
    end

    def handle_callback({:error, data}, state) do
        "Something went wrong :("
    end

    def refresh(channelid) do
        token_record = Evixir.ESI.Token |> Ecto.Query.where(channel_id: ^channelid) |> Evixir.Repo.one
        OAuth2.Client.get_token(client, [code: "", refresh_token: token_record.refresh_token, grant_type: "refresh_token"], [{"Authorization", auth_header()}]) |> handle_refresh(token_record)
    end

    def handle_refresh({:ok, data}, token_record) do
        change = Evixir.ESI.Token.changeset(token_record, %{
            access_token: data.token.access_token,
            expires_at: data.token.expires_at,
            refresh_token: data.token.refresh_token,
            token_type: data.token.token_type
        })
        Evixir.Repo.update!(change)
    end
end
