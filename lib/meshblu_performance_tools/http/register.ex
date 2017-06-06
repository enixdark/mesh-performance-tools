defmodule MeshbluPerformanceTools.HTTP.Register do
  use GenServer
  require Logger
  require IEx

  def start_link(args) do
    Logger.info "start register...................."
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(args) do
    {:ok, {%{}, []}}
  end
  
  def handle_cast({:register, uri}, state) do
    p = get(elem(state, 0))
    MeshbluPerformanceTools.HTTP.Process.subscribe(p, "", "")
    {:noreply, state}
    # case HTTPotion.post uri, 
    #    [body: body |> Poison.encode!,
    #    headers: ["Content-Type": "application/json"]] do
    #   %HTTPotion.Response{body: content} ->
    #     IO.puts content
    #     p = get(elem(state, 0))
    #     res = content |> Poison.decode!
    #     MeshbluPerformanceTools.Tools.Process.subscribe(p, res["uuid"], res["token"])
    #     {:noreply, { elem(state,0), elem(state,1) ++ [content]}}
    #   _ ->
    #     {:noreply, state}
    # end
    
  end

  def register(pid, uri \\ Application.get_env(:meshblu_performance_tools, :uri)) do
    GenServer.cast(pid, {:register, uri})
  end

  defp get(state) do
    p = Map.get(state,:pid, nil)
    if p == nil do
      %URI{scheme: protocol, host: stream_host, port: stream_port} = URI.parse(Application.get_env(:meshblu_performance_tools, :stream_uri))
      {:ok, p } = MeshbluPerformanceTools.Process.start_link(%{
        protocol: protocol,
        host: stream_host,
        port: stream_port
      })
      Map.put(state,:pid, p)
    end
    p
  end 

  
end