require IEx;

defmodule Mix.Tasks.Mqtt do
  use Mix.Task
  use Mix.Tasks.Base
  require Logger

  @shortdoc "return mqtt"

  def title do
    "mqtt"
  end

  defp process(opts) do
    case opts do
      [concurrency: concurrency, delay: delay, max_connection: max_connection, uri: uri] -> 
        Logger.info "Start services..................."
        turn = max_connection / concurrency - 1
        for _ <- 0..round(turn) do
          for _ <- 0..round(concurrency) do 
            {:ok, pid} =  MeshbluPerformanceTools.MQTT.Client.start_link
            MeshbluPerformanceTools.MQTT.Client.subscriber(pid)
          end
          :timer.sleep(delay)
        end
       _ ->
         :ok
    end
    loop()
  end

end