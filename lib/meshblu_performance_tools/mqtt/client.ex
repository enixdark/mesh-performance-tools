defmodule MeshbluPerformanceTools.MQTT.Client do
  use GenServer
  require Logger

  def start_link(args \\ []) do
    # Logger.info "start mqtt...................."
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(args), do: {:ok, args}

  
  def handle_cast({:subscribe, uri, uuid, token}, state) do
    {:ok, new_state} = handle_subscriber(uri, uuid, token, state)
    {:noreply, new_state}
  end

  defp handle_subscriber(uri, uuid, token, state) do
    _uri = URI.parse(uri)
    {:ok, pid } = MeshbluPerformanceTools.MQTT.Process.start_link([host: _uri.host, port: _uri.port, username: uuid, password: token])
    :timer.sleep(100)
    MeshbluPerformanceTools.MQTT.Process.sub(pid, uuid, 0)
    {:ok, state ++ [pid: pid]}
  end

  def subscriber(pid, uri, uuid, token), do: GenServer.cast(pid, {:subscribe, uri, uuid, token}) 

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end