defmodule Evixir.ESI.Killmail do
    use Task

    def start_link(_arg) do
      Task.start_link(&poll/0)
    end
    
    def poll() do
      receive do
      after
        60_000 ->
          get_price()
          poll()
      end
    end
    
    defp get_price() do
      Nostrum.Api.create_message(277457057806942208, "test")
    end
  end