require IEx;

defmodule Mix.Tasks.Cli do
  use Mix.Task
  require Logger

  @shortdoc "return cli"
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


  defp process(:help) do
    IO.puts """
      Cli tool to test performance for meshblu

      Options:
        -c, --concurrency  Number of concurrent requests. Default: 1
        -n, --max_connection        Max number of total requests. Default: 10
        -d, --delay        Delay time for every request. Default: 1
        -u, --uri    App      request to uri of meshblu service . Default: localhost:3000
        -s, --stream_uri   request to uri of stream meshblu service. Default: localhost:3001
        -l, --logpath      path to save log
    """
    System.halt(0)
  end

  defp process(opts) do
    IO.inspect opts
    case opts do
      [concurrency: concurrency, delay: delay, max_connection: max_connection, stream_uri: stream_uri, uri: uri] -> 
         Application.put_env(:meshblu_performance_tools, :concurrency, concurrency)
         Application.put_env(:meshblu_performance_tools, :uri, uri)
         Application.put_env(:meshblu_performance_tools, :stream_uri, stream_uri)
         Application.put_env(:meshblu_performance_tools, :delay, delay)
         Application.put_env(:meshblu_performance_tools, :max_connection, max_connection)
         IO.puts Application.get_env(:meshblu_performance_tools, :max_connection)
         Logger.info "Start services..................."
         tasks = Enum.map(1..10, fn(i) -> Task.async(fn -> :poolboy.transaction(
                          :register,
                          fn(id) -> 
                            MeshbluPerformanceTools.Register.register(id, uri)
                          end,
                          Application.get_env(:meshblu_performance_tools, :timeout)
                        )
           end)
         end)
         Enum.each(tasks, fn(task) -> IO.inspect(Task.await(task, Application.get_env(:meshblu_performance_tools, :timeout))) end)
       _ ->
         :ok
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