require IEx;

defmodule Mix.Tasks.Http do
  use Mix.Task
  use Mix.Tasks.Base
  require Logger


  @shortdoc "return http"
  def title do
    "http"
  end

  

  defp process(opts, [head|data], count, persistent_auth) do
    case opts do
      [concurrency: concurrency, delay: delay, level: _, max_connection: max_connection, mode: :unique, uri: uri] ->        
        :poolboy.transaction(:http,
                          fn(id) -> 
                            MeshbluPerformanceTools.HTTP.Register.subscriber(id, uri, head[:uuid], head[:token])
                          end,5000)
        if rem(count, concurrency) == 0, do: :timer.sleep(delay)                  
        if(count == max_connection) do''
          Logger.info "complete connect"
          loop()
        end
        process(opts, data, count + 1, nil)
      [concurrency: concurrency, delay: delay, level: :once, max_connection: _, mode: _, uri: uri] ->        
        :poolboy.transaction(:http,
                          fn(id) -> 
                            MeshbluPerformanceTools.HTTP.Register.subscriber(id, uri, head[:uuid], head[:token])
                          end,5000)
        if rem(count, concurrency) == 0, do: :timer.sleep(delay)                  
        if(data == []) do 
          Logger.info "complete connect"
          loop()
        end
        process(opts, data, count + 1, nil)
      [concurrency: concurrency, delay: delay, force: _, level: :multi, max_connection: max_connection, mode: _, uri: uri] -> 
        :poolboy.transaction(:http,
                          fn(id) -> 
                            MeshbluPerformanceTools.HTTP.Register.subscriber(id, uri, head[:uuid], head[:token])
                          end,5000)
        if rem(count, concurrency) == 0, do: :timer.sleep(delay)
        if(count == max_connection) do''
          Logger.info "complete connect"
          loop()
        end
        cond do
          data == [] -> process(opts, persistent_auth, count + 1, persistent_auth)
          true -> process(opts, data, count + 1, persistent_auth)
        end
       _ ->
         :ok
    end
    
  end

end