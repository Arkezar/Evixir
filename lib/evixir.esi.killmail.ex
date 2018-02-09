defmodule Evixir.ESI.Killmail do
    use Task
    require Ecto.Query

    def start_link(_arg) do
      Task.start_link(&poll/0)
    end
    
    def poll() do
      receive do
      after
        300_000 ->
          get_kms()
          poll()
      end
    end
    
    def get_kms() do
      channels = Evixir.Repo.all(Evixir.ESI.Channel) |> Evixir.Repo.preload(:token)
      Enum.each channels, &sync_channel_async(&1)
    end

    def sync_channel_async(channel) do
      spawn(fn ->
        sync_channel(channel)
      end)
    end

    def sync_channel(channel) do
      recent_kms = Enum.reverse(Enum.take_while(get_recent_killmails(channel.corporation_id, channel.token), fn(x) -> x["killmail_id"] > channel.last_killmail end))
      Enum.each recent_kms, (&gen_killmail(&1, channel.corporation_id) |> post_killmail(channel.channel_id))
    end

    def post_killmail(data, channel_id) do
      Nostrum.Api.create_message(channel_id, data.msg) |> handle_post_killmail(data.killmail_id)
    end

    def handle_post_killmail({:ok, data}, killmail_id) do
      record = Evixir.ESI.Channel |> Ecto.Query.where(channel_id: ^data.channel_id) |> Evixir.Repo.one
      change = Evixir.ESI.Channel.changeset(record, %{
        last_killmail: killmail_id
      })
      Evixir.Repo.update!(change)
    end

    def gen_killmail(killmail, corp_id) do
      url = "https://esi.tech.ccp.is/latest/killmails/" <> to_string(killmail["killmail_id"]) <> "/" <> to_string(killmail["killmail_hash"]) <> "/"
      km_data = HTTPotion.get(url, headers: ["X-User-Agent": "Evixir"]).body |> Poison.decode!

      ship_id = km_data["victim"]["ship_type_id"]
      victim_data = Evixir.ESI.Character.get_character_info(km_data["victim"]["character_id"])
      victim_corp_name = Evixir.ESI.Corporation.get_corporation_info(km_data["victim"]["corporation_id"])["name"]
      killer = Enum.find(km_data["attackers"], &(&1["final_blow"]))
      killer_data = Evixir.ESI.Character.get_character_info(killer["character_id"])
      killer_corp_name = Evixir.ESI.Corporation.get_corporation_info(killer["corporation_id"])["name"]
      item_data = Evixir.ESI.Market.get_item_data(ship_id)

      value = get_kill_value([ %{ "quantity_destroyed" => 1, "item_type_id" => ship_id} | km_data["victim"]["items"]])
      embeds = %Nostrum.Struct.Embed{
        title: "Killmail #" <> to_string(killmail["killmail_id"]),
        url: "https://zkillboard.com/kill/" <> to_string(killmail["killmail_id"]) <> "/",
        color: if(km_data["victim"]["corporation_id"] == corp_id) do Integer.parse("ff0000", 16) else Integer.parse("00ff00", 16) end,
        thumbnail: %Nostrum.Struct.Embed.Thumbnail{url: "https://imageserver.eveonline.com/Type/" <> to_string(ship_id) <> "_64.png"},
        timestamp: km_data["killmail_time"],
        fields: [
          %Nostrum.Struct.Embed.Field{inline: true, name: "Victim", value: victim_data["name"] || "N/A"},
          %Nostrum.Struct.Embed.Field{inline: true, name: "Corporation", value: victim_corp_name || "N/A"},
          %Nostrum.Struct.Embed.Field{inline: true, name: "Type", value: item_data.group["name"] || "N/A"},
          %Nostrum.Struct.Embed.Field{inline: true, name: "Ship", value: item_data.info["name"] || "N/A"},
          %Nostrum.Struct.Embed.Field{inline: true, name: "Killer", value: killer_data["name"] || "N/A"},
          %Nostrum.Struct.Embed.Field{inline: true, name: "Corporation", value: killer_corp_name || "N/A"},
          %Nostrum.Struct.Embed.Field{inline: true, name: "Value", value: Money.to_string(Money.parse!(value / 1, :ISK)) <> " ISK"}
        ]
      }
      %{msg: [content: "", embed: embeds], killmail_id: killmail["killmail_id"]}
    end

    def get_kill_value(items) do
      List.foldl(items, 0, fn(x, acc) -> acc + (((x["quantity_destroyed"] || 0) + (x["quantity_dropped"] || 0)) * Evixir.ESI.Market.get_lowest_item_price(x["item_type_id"])["price"]) end)
    end

    def get_recent_killmails(corp_id, token) do
      token = get_token_for_request(token)
      url = "https://esi.tech.ccp.is/latest/corporations/" <> to_string(corp_id) <> "/killmails/recent/"
      HTTPotion.get(url, headers: ["Authorization": "Bearer " <> token.access_token, "X-User-Agent": "Evixir"]).body |> Poison.decode!
    end

    def get_token_for_request(token) do
      unless DateTime.diff(DateTime.from_unix!(token.expires_at - 5), DateTime.utc_now) > 0 do
        Evixir.ESI.Authentication.refresh(token.channel_id)
      else
        token
      end
    end
  end