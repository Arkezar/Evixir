defmodule Evixir.ESI.Corporation do
    def get_corporation_info(corp_id) do
        HTTPotion.get("https://esi.tech.ccp.is/latest/corporations/" <> to_string(corp_id) <> "/", headers: ["X-User-Agent": "Evixir"]).body |> Poison.decode!
    end
end