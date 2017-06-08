require IEx;

defmodule Mix.Tasks.Http do
  use Mix.Task
  require Logger

  @shortdoc "return http"
  defp parse_args(args) do
    parse = args 
    |> OptionParser.parse(
      switches: [logpath: :string , concurrency: :integer, max_connection: :integer, delay: :integer, host: :string, port: :string, protocol: :string],
      aliases: [l: :logpath , c: :concurrency, n: :max_connection, d: :delay, u: :uri, s: :stream_uri, h: :host, p: :port, P: :protocol],
    )

    case parse do
      {[], _, _} -> process(:help)
      {opts, _, _} -> 
        uri = URI.parse(Dict.get(opts,:host, nil) || Application.get_env(:meshblu_performance_tools, :uri))
        host = uri.host
        port = Dict.get(opts,:port, nil)  || uri.port
        protocol = Dict.get(opts,:protocol, nil)  || uri.scheme
        process(Keyword.merge([concurrency: Dict.get(opts,:concurrency, nil) || Application.get_env(:meshblu_performance_tools, :concurrency), 
                                             max_connection: Dict.get(opts,:max_connection, nil)  || Application.get_env(:meshblu_performance_tools, :max_connection), 
                                             delay: Dict.get(opts,:delay, nil) || Application.get_env(:meshblu_performance_tools, :delay), 
                                             uri: "#{protocol}://#{host}:#{port}"], 
                                             opts) |> Enum.sort)
                                            
      
    end
  end


  defp process(:help) do
    IO.puts """
      Cli tool to test performance for meshblu http

      Options:
        -c, --concurrency  Number of concurrent requests. Default: 1
        -n, --max_connection        Max number of total requests. Default: 10
        -d, --delay        Delay time for every request. Default: 1
        -h, --host   request to hostname of meshblu service . Default: localhost
        -p, --port   request to port of meshblu service . Default: 3000
        -P, --protocol   protocol of meshblu service . Default: 3000
        -s, --stream_host   request to uri of stream meshblu service. Default: localhost:3001
        -, --stream_host   request to uri of stream meshblu service. Default: localhost:3001
        -l, --logpath      path to save log
    """
    System.halt(0)
  end

  defp process(opts) do
    IO.inspect opts
    case opts do
      [concurrency: concurrency, delay: delay, max_connection: max_connection, uri: uri] -> 
         
         IO.puts Application.get_env(:meshblu_performance_tools, :max_connection)
         Logger.info "Start services..................."
         tasks = Enum.map(1..1, fn(_) -> Task.async(fn -> :poolboy.transaction(
                          :http,
                          fn(id) -> 
                            MeshbluPerformanceTools.HTTP.Register.subscriber(id, uri)
                          end,
                          Application.get_env(:meshblu_performance_tools, :timeout)
                        )
           end)
         end)
         Enum.each(tasks, fn(task) -> IO.inspect(Task.await(task, Application.get_env(:meshblu_performance_tools, :timeout))) end)
       _ ->
         :ok
    end
    loop()
  end

  def loop() do
    receive do
      _ -> loop()
    end
  end


  def run(args) do
    Process.flag(:trap_exit, true)
    Mix.Task.run "app.start", []
    args 
    |> parse_args 
    |> process
  end

end