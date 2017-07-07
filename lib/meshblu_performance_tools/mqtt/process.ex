defmodule MeshbluPerformanceTools.MQTT.Process do
  use GenMQTT
  require Logger
  require IEx
  def start_link(opts \\ []) do
    GenMQTT.start_link(MeshbluPerformanceTools.MQTT.Process, self(), opts)
  end

  def sub(pid, topic \\ "message", qos \\ 0) do
    GenMQTT.subscribe(pid, topic, qos)
  end

  def pub(pid, topic \\ "message", message \\ Poison.encode!(%{topic: "message", devices: ["47706d7d-a6db-4edd-b7a1-f7aebc5bef4e"], payload: "helo owlrd"}) , qos \\ 0, retrain \\ false) do
    GenMQTT.publish(pid, topic, message, qos, retrain)
  end

  def on_connect(state) do
    if System.get_env("MESH_DEBUG") do
      Logger.info "#{:erlang.pid_to_list(self())} connected"
    end
    :ets.insert(:total, {:erlang.pid_to_list(self())})
    send state, :connected
    {:ok, state}
  end

  # def on_connect_error(reason, state) do
  #   send state, :connected_error
  #   {:ok, state}
  # end

  def on_publish(topic, message, state) do
    if System.get_env("MESH_DEBUG") do
      Logger.info "#{:erlang.pid_to_list(self())} #{inspect(message)} received"
    end
    :ets.insert(:messages, {:erlang.pid_to_list(self())})
    send state, {:published, self, topic, message}
    {:ok, state}
  end

  def on_subscribe(subscription, state) do
    if System.get_env("MESH_DEBUG") do
      Logger.info "#{:erlang.pid_to_list(self())} subscribed"
      Logger.info inspect(subscription)
    end
    send state, {:subscribed, subscription}
    {:ok, state}
  end

  def terminate(var, state) do
    if System.get_env("MESH_DEBUG") do
      Logger.error "#{var} #{:erlang.pid_to_list(self())} terminated #{state}"
    end
    :ets.insert(:errors, {:erlang.pid_to_list(self())})
    send state, :shutdown
    :ok
  end
  
  # def terminate(:normal, state) do
  #   Logger.error "#{:erlang.pid_to_list(self())} terminated"
  #   send state, :shutdown
  #   :ok
  # end

  def terminate(_reason, _state) do
    if System.get_env("MESH_DEBUG") do
      Logger.error "#{:erlang.pid_to_list(self())} terminated"
    end
    :ets.insert(:errors, {:erlang.pid_to_list(self())})
    :ok
  end

  # def handle_info(msg, state) do
  #   {:noreply, state}
  # end
  
  

  
end