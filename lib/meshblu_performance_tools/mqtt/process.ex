defmodule MeshbluPerformanceTools.MQTT.Process do
  use GenMQTT
  require Logger
  require IEx
  def start_link(opts \\ [host: "localhost", port: 1883, username: "47706d7d-a6db-4edd-b7a1-f7aebc5bef4e", password: "e6869b631aa3d521a842752f8ed7300d62fa9332"]) do
    GenMQTT.start_link(__MODULE__, self(), opts)
  end

  def sub(pid, topic \\ "message", qos \\ 0) do
    GenMQTT.subscribe(pid, topic, qos)
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
    # IO.inspect "connected"
    send state, :connected
    {:ok, state}
  end

  def on_publish(topic, message, state) do
    IO.inspect message
    send state, {:published, self, topic, message}
    {:ok, state}
  end

  def on_subscribe(subscription, state) do
    # IO.inspect subscription
    send state, {:subscribed, subscription}
    {:ok, state}
  end

  def terminate(:normal, state) do
    # IO.inspect "terminate"
    send state, :shutdown
    :ok
  end

  def terminate(_reason, _state) do
    # IO.inspect "terminate"
    :ok
  end
  
  

  
end