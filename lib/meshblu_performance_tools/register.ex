defmodule MeshbluPerformanceTools.Tools.Register do
  use GenServer
  require Logger
  require IEx

  def start_link() do
    Logger.info "start request...................."
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(_) do
    {:ok, {%{}, []}}
  end
  
  def handle_cast({:register, uri, body}, state) do
    # p = get(elem(state, 0))
    # MeshbluPerformanceTools.Tools.Process.subscribe(p, "", "")
    # {:noreply, state}
    case HTTPotion.post uri, 
       [body: body |> Poison.encode!,
       headers: ["Content-Type": "application/json"]] do
      %HTTPotion.Response{body: content} ->
        IO.puts content
        p = get(elem(state, 0))
        res = content |> Poison.decode!
        MeshbluPerformanceTools.Tools.Process.subscribe(p, res["uuid"], res["token"])
        {:noreply, { elem(state,0), elem(state,1) ++ [content]}}
      _ ->
        {:noreply, state}
    end
    
  end

  def register(pid, uri \\ MeshbluPerformanceTools.Tools.Const.device_uri, 
               body \\ MeshbluPerformanceTools.Tools.Const.version_2) do
    GenServer.cast(pid, {:register, uri, body})
  end

  defp get(state) do
    p = Map.get(state,:pid, nil)
    if p == nil do
      {:ok, p } = MeshbluPerformanceTools.Tools.Process.start_link()
      Map.put(state,:pid, p)
    end
    p
  end 

  
end