defmodule MeshbluPerformanceTools.Tools.Register do
  use GenServer
  require Logger
  require IEx

  def start_link([]) do
    Logger.info "start request...................."
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(_) do
    {:ok, %{}}
  end
  

  def register(uri \\ MeshbluPerformanceTools.Tools.Const.device_uri, 
               body \\ MeshbluPerformanceTools.Tools.Const.version_2) do
    
    case HTTPotion.post uri, 
       [body: body |> Poison.encode!,
       headers: ["Content-Type": "application/json"]] do
      %HTTPotion.Response{body: content} ->
        content
      _ ->
        :error   
    end
  end
end