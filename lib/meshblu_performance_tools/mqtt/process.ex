defmodule MeshbluPerformanceTools.MQTT.Process do
  use GenMQTT
  require Logger
  require IEx
  def start_link(opts \\ []) do
    GenMQTT.start_link(__MODULE__, self(), opts)
  end

  def sub(pid, topic \\ "message", qos \\ 0) do
    GenMQTT.subscribe(pid, "8bdec525-f2d0-49cf-a948-b2819d837f19", qos)
    # loop(pid)
  end


  def loop(pid) do
    receive do
      _ -> loop(pid)
    end
  end

  def pub(pid, topic \\ "message", message \\ Poison.encode!(%{topic: "message", devices: ["47706d7d-a6db-4edd-b7a1-f7aebc5bef4e"], payload: "helo owlrd"}) , qos \\ 0, retrain \\ false) do
    GenMQTT.publish(pid, topic, message, qos, retrain)
  end

  def on_connect(state) do
    # Logger.info "#{:io.list_to_pid(self())} connected"
    send state, :connected
    {:ok, state}
  end

  # def on_connect_error(reason, state) do
  #   send state, :connected_error
  #   {:ok, state}
  # end

  def on_publish(topic, message, state) do
    Logger.info "#{:erlang.pid_to_list(self())} received"
    send state, {:published, self, topic, message}
    {:ok, state}
  end

  def on_subscribe(subscription, state) do
    Logger.info "#{:erlang.pid_to_list(self())} subscribed"
    send state, {:subscribed, subscription}
    {:ok, state}
  end

  def terminate(var, state) do
    Logger.error "#{var} #{:erlang.pid_to_list(self())} terminated"
    send state, :shutdown
    :ok
  end
  
  # def terminate(:normal, state) do
  #   Logger.error "#{:erlang.pid_to_list(self())} terminated"
  #   send state, :shutdown
  #   :ok
  # end

  def terminate(_reason, _state) do
    Logger.error "#{:erlang.pid_to_list(self())} terminated"
    :ok
  end

  # def handle_info(msg, state) do
  #   IEx.pry
  #   {:noreply, state}
  # end
  
  

  
end