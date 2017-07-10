defmodule MeshbluPerformanceTools.MQTT.Process do
  use GenMQTT
  require Logger
  require IEx
  def start_link(opts \\ []) do
    GenMQTT.start_link(MeshbluPerformanceTools.MQTT.Process, opts, opts)
  end

  def init(opts) do
    {:ok, opts}
  end

  def sub(pid, topic \\ "message", qos \\ 0) do
    GenMQTT.subscribe(pid, topic, qos)
  end

  def pub(pid, topic \\ "message", message \\ Poison.encode!(%{topic: "message", devices: ["47706d7d-a6db-4edd-b7a1-f7aebc5bef4e"], payload: "helo world"}) , qos \\ 0, retrain \\ false) do
    GenMQTT.publish(pid, topic, message, qos, retrain)
  end

  def on_connect(state) do
    if System.get_env("MESH_DEBUG") do
      Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), type: :connect, time: :os.system_time(:millisecond)}
    end
    :ets.insert(:total, {:erlang.pid_to_list(self())})
    send self(), :connected
    {:ok, state}
  end

  def on_publish(topic, message, state) do
    if System.get_env("MESH_DEBUG") do
      Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), message: inspect(message), type: :receive, time: :os.system_time(:millisecond), topic: inspect(topic)}
    end
    :ets.insert(:messages, {:erlang.pid_to_list(self())})
    send self(), {:published, self, topic, message}
    {:ok, state}
  end

  def on_subscribe(subscription, state) do
    if System.get_env("MESH_DEBUG") do
      Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), type: :subscribe, time: :os.system_time(:millisecond), subscription: inspect(subscription)}
      Logger.info inspect(subscription)
    end
    send self(), {:subscribed, subscription}
    {:ok, state}
  end

  def terminate(var, state) do
    if System.get_env("MESH_DEBUG") do
      Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), type: :terminated, time: :os.system_time(:millisecond), reason: inspect(var)}
    end
    :ets.insert(:errors, {:erlang.pid_to_list(self())})
    send self(), :shutdown
    :ok
  end
  
  # def terminate(:normal, state) do
  #   Logger.error "#{:erlang.pid_to_list(self())} terminated"
  #   send state, :shutdown
  #   :ok
  # end

  # def terminate(_reason, _state) do
  #   if System.get_env("MESH_DEBUG") do
  #     Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), type: :terminated, time: :os.system_time(:millisecond), reason: nil}
  #   end
  #   :ets.insert(:errors, {:erlang.pid_to_list(self())})
  #   :ok
  # end

  # def handle_info(msg, state) do
  #   {:noreply, state}
  # end



  def on_disconnect(state) do
    if System.get_env("MESH_DEBUG") do
      Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), type: :disconnect, time: :os.system_time(:millisecond)}
    end
    send state, :disconnected
    {:ok, state}
  end
  
  def on_connect_error(reason, state) do
    if System.get_env("MESH_DEBUG") do
      Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), type: :connect_error, time: :os.system_time(:millisecond), reason: reason}
    end
    send state, :connected_error
    {:ok, state}
  end
  

  
end