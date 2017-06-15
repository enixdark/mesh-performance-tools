require IEx;

defmodule Mix.Tasks.Http do
  use Mix.Task
  use Mix.Tasks.Base

  @shortdoc "return http"
  def title do
    :http
  end

  def handle_event(uuid, token, options) do

    {:ok, pid} = MeshbluPerformanceTools.HTTP.Register.start_link([])
    MeshbluPerformanceTools.HTTP.Register.subscriber(pid, options[:uri], uuid, token)
    
  end

  def process(opts, [head|data], count, persistent_auth) do
    case opts do
      [concurrency: concurrency, delay: delay, level: _, max_connection: max_connection, mode: :unique, uri: uri] -> 
        handle_event(head[:uuid], head[:token], opts)  
        if (rem(count, concurrency) == 0) do
          Logger.info "### delay time at: <<#{System.system_time(:second)}>>"
          :timer.sleep(delay)    
        end
        if (count == max_connection) do
           Logger.info "complete all request at: <<#{System.system_time(:second)}>>"
           loop()
        end
        process(opts, data, count + 1, nil)
      [concurrency: concurrency, delay: delay, level: :once, max_connection: _, mode: _, uri: uri] -> 
        handle_event(head[:uuid], head[:token], opts) 
        if rem(count, concurrency) == 0 do
          Logger.info "### delay time at: <<#{System.system_time(:second)}>>"
          :timer.sleep(delay)    
        end                 
        if (data == []) do
          Logger.info "complete all request at: <<#{System.system_time(:second)}>>"
          loop()
        end
        process(opts, data, count + 1, nil)
      [concurrency: concurrency, delay: delay, force: _, level: :multi, max_connection: max_connection, mode: _, uri: uri] -> 
        handle_event(head[:uuid], head[:token], opts) 
        if rem(count, concurrency) == 0 do
          Logger.info "### delay time at: <<#{System.system_time(:second)}>>"
          :timer.sleep(delay)    
        end
        if (count == max_connection) do 
          Logger.info "complete all request at: <<#{System.system_time(:second)}>>"
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