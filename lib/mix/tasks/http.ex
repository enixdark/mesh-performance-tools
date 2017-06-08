require IEx;

defmodule Mix.Tasks.Http do
  use Mix.Task
  use Mix.Tasks.Base
  require Logger


  @shortdoc "return http"
  


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
        -l, --logpath      path to save log
    """
    System.halt(0)
  end

  defp process(opts) do
    IO.inspect opts
    case opts do
      [concurrency: concurrency, delay: delay, max_connection: max_connection, uri: uri] -> 
         
         Logger.info "Start services..................."
         turn = max_connection / concurrency - 1
         for _ <- 0..round(turn) do
            tasks = Enum.map(1..round(concurrency), fn(_) -> Task.async(fn -> :poolboy.transaction(
                            :http,
                            fn(id) -> 
                              MeshbluPerformanceTools.HTTP.Register.subscriber(id, uri)
                            end,
                            Application.get_env(:meshblu_performance_tools, :timeout)
                          )
            end)
          end)
          Enum.each(tasks, fn(task) -> IO.inspect(Task.await(task, Application.get_env(:meshblu_performance_tools, :timeout))) end)
          :timer.sleep(delay)
         end
       _ ->
         :ok
    end
    loop()
  end

end