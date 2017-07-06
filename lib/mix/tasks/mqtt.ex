defmodule Mix.Tasks.Mqtt do
  use Mix.Task
  use Mix.Tasks.Base
  @shortdoc "return mqtt"

  def title do
    :mqtt
  end

  def handle_event(uuid, token, options) do
    {:ok, pid} =  MeshbluPerformanceTools.MQTT.Client.start_link
    MeshbluPerformanceTools.MQTT.Client.subscriber(pid, options[:uri], uuid, token)     
  end

  def process(opts, [head|data], count, persistent_auth) do
    case opts do
      [concurrency: concurrency, delay: delay, level: _, max_connection: max_connection, mode: :unique, uri: uri] -> 

        handle_event(head[:uuid], head[:token], opts)  
        if (rem(count, concurrency) == 0) do
          :timer.sleep(delay)    
        end
        if (count >= max_connection) do
            wait()
        end
        process(opts, data, count + 1, nil)
      [concurrency: concurrency, delay: delay, level: :once, max_connection: max_connection, mode: _, uri: uri] -> 
        handle_event(head[:uuid], head[:token], opts) 
        if rem(count, concurrency) == 0 do
          :timer.sleep(delay)    
        end                 
        if (data == [] || count == max_connection) do
          wait()
        end
        process(opts, data, count + 1, nil)
      [concurrency: concurrency, delay: delay, force: _, level: :multi, max_connection: max_connection, mode: _, uri: uri] -> 
        handle_event(head[:uuid], head[:token], opts) 
        if rem(count, concurrency) == 0 do
          :timer.sleep(delay)    
        end
        if (count >= max_connection) do 
          wait()
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


