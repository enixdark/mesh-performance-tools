defmodule MeshbluPerformanceTools.MQTT.Client do
  use GenServer
  # use GenMQTT
  require Logger
  require IEx

  def start_link(args \\ [host: "localhost", port: 1883, uuid: "47706d7d-a6db-4edd-b7a1-f7aebc5bef4e", token: "e6869b631aa3d521a842752f8ed7300d62fa9332"]) do
    # Logger.info "start mqtt...................."
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(args), do: {:ok, args}

  def handle_cast(:subscribe, state) do
    {:ok, pid } = MeshbluPerformanceTools.MQTT.Process.start_link([host: state[:host], port: state[:port], username: state[:uuid], password: state[:token]])
    :timer.sleep(1000)
    MeshbluPerformanceTools.MQTT.Process.sub(pid, state[:uuid], 0)
    {:noreply, state ++ [pid: pid]}
  end

  def subscriber(pid) do
    GenServer.cast(pid, :subscribe) 
  end
  
end