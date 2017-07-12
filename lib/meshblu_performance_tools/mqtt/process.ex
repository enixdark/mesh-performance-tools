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

  def pub(pid, topic \\ "message", message \\ Poison.encode!(%{}) , qos \\ 0, retrain \\ false) do
    GenMQTT.publish(pid, topic, message, qos, retrain)
  end

  def on_connect(state) do
    Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), type: :connect, time: System.system_time(:millisecond)}
    send self(), :connected
    {:ok, state}
  end

  def on_publish(topic, message, state) do
    Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), message: inspect(message), type: :receive, time: System.system_time(:millisecond), topic: inspect(topic)}
    send self(), {:published, self, topic, message}
    {:ok, state}
  end

  def on_subscribe(subscription, state) do
    Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), type: :subscribe, time: System.system_time(:millisecond), subscription: inspect(subscription)}
    send self(), {:subscribed, subscription}
    {:ok, state}
  end

  def terminate(var, state) do
    Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), type: :terminated, time: System.system_time(:millisecond), reason: inspect(var)}
    send self(), :shutdown
    :ok
  end
  
  def on_disconnect(state) do
    Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), type: :disconnect, time: System.system_time(:millisecond)}
    send state, :disconnected
    {:ok, state}
  end
  
  def on_connect_error(reason, state) do
    Logger.info Poison.encode! %{host: state[:host], uuid: state[:username], token: state[:password], pid: :erlang.pid_to_list(self()), type: :connect_error, time: System.system_time(:millisecond), reason: reason}
    send state, :connected_error
    {:ok, state}
  end
  

  
end