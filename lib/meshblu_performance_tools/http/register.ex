defmodule MeshbluPerformanceTools.HTTP.Register do
  use GenServer
  require Logger

  def start_link(args) do
    # Logger.info "start register...................."
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(args) do
    {:ok, {%{}, []}}
  end


  def handle_subscriber(state, uri, uuid \\ nil, token \\ nil) do
    pid = get(elem(state, 0), uri)
    MeshbluPerformanceTools.HTTP.Process.subscriber(pid, uuid, token)
  end
  
  def handle_cast({:subscriber, uri}, state) do
    handle_subscriber(state, uri)
    {:noreply, state} 
  end

  def handle_cast({:subscriber, uri, uuid, token}, state) do
    handle_subscriber(state, uri, uuid, token)
    {:noreply, state} 
  end

  def handle_cast({:register, uri, body}, state) do
    case HTTPotion.post uri, 
       [body: body |> Poison.encode!,
       headers: ["Content-Type": "application/json"]] do
      %HTTPotion.Response{body: content} ->
        # p = get(elem(state, 0))
        res = content |> Poison.decode!
        # MeshbluPerformanceTools.Tools.Process.subscribe(p, res["uuid"], res["token"])
        {:noreply, { elem(state,0), elem(state,1) ++ [uuid: res["uuid"], token: res["token"]]}}
      _ ->
        {:noreply, state}
    end
  end

  def subscriber(pid, uri) do
    GenServer.cast(pid, {:subscriber, uri})
  end

  def subscriber(pid, uri, uuid, token) do
    GenServer.cast(pid, {:subscriber, uri, uuid, token})
  end

  def register({pid, uri}) do
    GenServer.cast(pid, {:subscriber, uri})
  end

  defp get(state, uri) do
    p = Map.get(state,:pid, nil)
    if p == nil do
      %URI{scheme: protocol, host: stream_host, port: stream_port} = URI.parse(uri)
      {:ok, p } = MeshbluPerformanceTools.HTTP.Process.start_link(%{
        protocol: protocol,
        host: stream_host,
        port: stream_port
      })
      Map.put(state,:pid, p)
    end
    p
  end 

  
end