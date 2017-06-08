require IEx;

defmodule Mix.Tasks.Mqtt do
  use Mix.Task
  require Logger

  @shortdoc "return mqtt"
  defp parse_args(args) do
    parse = args 
    |> OptionParser.parse(
      switches: [logpath: :string , concurrency: :integer, max_connection: :integer, delay: :integer, uri: :string, stream_uri: :string],
      aliases: [l: :logpath , c: :concurrency, n: :max_connection, d: :delay, u: :uri, s: :stream_uri],
    )
    case parse do
      {[], _, _} -> process(:help)
      {opts, _, _} -> process(Keyword.merge([concurrency: Application.get_env(:meshblu_performance_tools, :concurrency), 
                                             max_connection: Application.get_env(:meshblu_performance_tools, :max_connection), 
                                             delay: Application.get_env(:meshblu_performance_tools, :delay), 
                                             uri: Application.get_env(:meshblu_performance_tools, :uri),
                                             stream_uri: Application.get_env(:meshblu_performance_tools, :stream_uri)], 
                                             opts) |> Enum.sort)
      
    end
  end

  defp loop() do
    receive do
      _ -> loop()
    end
  end


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
      [concurrency: _, delay: _, max_connection: _, stream_uri: _, uri: _] -> 
        Logger.info "Start services..................."
        for _ <- 0..1 do
          for _ <- 0..2 do 
            {:ok, pid} =  MeshbluPerformanceTools.MQTT.Client.start_link
            MeshbluPerformanceTools.MQTT.Client.subscriber(pid)
          end
          :timer.sleep(2000)
        end
       _ ->
         :ok
    end
    loop()
  end

  def run(args) do
    Process.flag(:trap_exit, true)    
    Mix.Task.run "app.start", []
    args 
    |> parse_args 
    |> process
  end

end