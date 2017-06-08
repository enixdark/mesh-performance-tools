require IEx;

defmodule Mix.Tasks.Mqtt do
  use Mix.Task
  use Mix.Tasks.Base
  require Logger

  @shortdoc "return mqtt"
  
  defp process(:help) do
    IO.puts """
      Cli tool to test performance for meshblu mqtt

      Options:
        -c, --concurrency  Number of concurrent requests. Default: 1
        -n, --max_connection        Max number of total requests. Default: 10
        -d, --delay        Delay time for every request. Default: 1
        -h, --host   request to hostname of meshblu service . Default: localhost
        -p, --port   request to port of meshblu service . Default: 3000
        -s, --protocol   protocol of meshblu service . Default: 3000
        -l, --logpath      path to save log
    """
    System.halt(0)
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