defmodule Evixir.ESI.Market do
    require HTTPotion

    def get_item_id(item_name) do
        content = "[\"" <> item_name <> "\"]"
        HTTPotion.post("https://esi.tech.ccp.is/latest/universe/ids/", body: content, headers: ["Content-Type": "application/json", "X-User-Agent": "Evixir"]) |> handle_get_item_id
    end

    def handle_get_item_id(response) do
        if HTTPotion.Response.success?(response) do
            Poison.decode!(response.body)["inventory_types"]
        end
    end

    def check_price(item_name) do
        item_id = get_item_id(item_name)
        case is_nil(item_id) do
            false -> get_item_price(item_id)
            true -> "Not found"
        end
    end

    def get_item_price(item_id) do
        id = hd(item_id)["id"]
        lowest_sell_price = get_lowest_item_price(id)
        graphic_url = "https://imageserver.eveonline.com/Type/" <> to_string(id) <> "_64.png"
        item_data = get_item_data(id)

        embeds = %Nostrum.Struct.Embed{
            title: "Eveprisal #" <> to_string(id),
            url: "https://evepraisal.com/item/" <> to_string(id),
            thumbnail: %Nostrum.Struct.Embed.Thumbnail{url: graphic_url},
            fields: [
                %Nostrum.Struct.Embed.Field{inline: true, name: "Type", value: item_data.group["name"]},
                %Nostrum.Struct.Embed.Field{inline: true, name: "Name", value: item_data.info["name"]},
                %Nostrum.Struct.Embed.Field{inline: true, name: "Region", value: "The Forge"},
                %Nostrum.Struct.Embed.Field{inline: true, name: "Price", value: Money.to_string(Money.parse!(lowest_sell_price["price"] / 1, :ISK)) <> " ISK"}
            ]
        }
        [content: "", embed: embeds]
    end

    def get_lowest_item_price(item_id) do
        url = "https://esi.tech.ccp.is/latest/markets/10000002/orders/?order_type=sell&type_id=" <> to_string(item_id)
        data = HTTPotion.get(url, headers: ["Content-Type": "application/json", "X-User-Agent": "Evixir"]).body
        |> Poison.decode!
        |> Enum.sort(&(&1["price"] <= &2["price"]))
        |> List.first
    end

    def get_item_data(item_id) do
        info_url = "https://esi.tech.ccp.is/latest/universe/types/" <> to_string(item_id) <> "/"
        info = HTTPotion.get(info_url, headers: ["accept": "application/json", "X-User-Agent": "Evixir"]).body |> Poison.decode!
        group_url = "https://esi.tech.ccp.is/latest/universe/groups/" <> to_string(info["group_id"]) <> "/"
        group = HTTPotion.get(group_url, headers: ["accept": "application/json", "X-User-Agent": "Evixir"]).body |> Poison.decode!
        %{info: info, group: group}
    end
end
