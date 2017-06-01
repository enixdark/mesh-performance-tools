defmodule Cli do
  @timeout 50_000

  require Logger
  defp parse_args(args) do
    parse = args 
    |> OptionParser.parse(
      switches: [logpath: :string , concurrency: :integer, total: :integer, delay: :integer, uri: :string, stream_uri: :string],
      aliases: [l: :logpath , c: :concurrency, n: :total, d: :delay, u: :uri, s: :stream_uri],
    )
    IO.inspect parse
    case parse do
      {[], _, _} -> process(:help)

      {opts, _, _} -> process(Keyword.merge([concurency: Application.get_env(:meshblu_performance_tools, :concurrency), 
                                             total: Application.get_env(:meshblu_performance_tools, :max_connection), 
                                             delay: Application.get_env(:meshblu_performance_tools, :delay), 
                                             uri: Application.get_env(:meshblu_performance_tools, :uri),
                                             stream_uri: Application.get_env(:meshblu_performance_tools, :stream_uri)], 
                                             opts))
    end
  end


  defp process(:help) do
    IO.puts """
      Cli tool to test performance for meshblu

      Options:
        -c, --concurrency  Number of concurrent requests. Default: 1
        -n, --total        Max number of total requests. Default: 10
        -d, --delay        Delay time for every request. Default: 1
        -u, --uri    App      request to uri of meshblu service . Default: localhost:3000
        -s, --stream_uri   request to uri of stream meshblu service. Default: localhost:3001
        -l, --logpath      path to save log
    """
    System.halt(0)
  end

  defp process(opts) do
    case opts do
      [concurency: _, total: _, delay: _, uri: uri, stream_uri: _] -> 
         Logger.info "Start services..................."
         tasks = Enum.map(1..Application.get_env(:meshblu_performance_tools, :concurrency), fn(i) -> Task.async(fn -> :poolboy.transaction(
                          :register,
                          fn(id) -> 
                            MeshbluPerformanceTools.Register.register(id)
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

  def main(args) do
    # Process.flag(:trap_exit, true)
    args 
    |> parse_args 
    |> process
  end

end