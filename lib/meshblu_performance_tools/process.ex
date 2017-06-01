defmodule MeshbluPerformanceTools.Process do
  use GenServer
  # require Timex
  require Logger
  require IEx 
  
  def start_link(args) do
    GenServer.start_link(__MODULE__,args, [])
  end

  def init(args) do
    {:ok, %{protocal: args[:protocal], host: args[:host], port: args[:port]}}
  end

  def subscribe(pid, uuid, token) do
    GenServer.cast(pid, {:subscribe, uuid, token})
  end

  def handle_cast({:subscribe, uuid, token}, state) do

    :ibrowse.set_max_sessions("http://#{state[:host]}", state[:port], 1000)

    {:ok, worker_pid} = HTTPotion.spawn_worker_process("http://#{state[:host]}:#{state[:port]}/subscribe")
    # IO.inspect worker_pid
    # case HTTPotion.get "http://#{state[:host]}:#{state[:port]}/subscribe", 
    #         [headers: ["meshblu_auth_uuid": uuid, "meshblu_auth_token": token], ibrowse: [direct: worker_pid, stream_to: {self(), :once}], timeout: 500_000] do
    # case HTTPotion.get "http://#{state[:host]}:#{state[:port]}/subscribe", [headers: ["meshblu_auth_uuid": "07d0fda7-2972-4aa7-b9d1-1c7e95adfe2f", "meshblu_auth_token": "ac17b5b772a1585df7fd61ff9bd6660cbbc7df0c"],
    #     ibrowse: [direct: worker_pid, stream_to: {self(), :once}], timeout: 100_000] do
     case HTTPotion.get "http://#{state[:host]}:#{state[:port]}/subscribe", [headers: ["meshblu_auth_uuid": "07d0fda7-2972-4aa7-b9d1-1c7e95adfe2f", "meshblu_auth_token": "ac17b5b772a1585df7fd61ff9bd6660cbbc7df0c"],
        ibrowse: [direct: worker_pid, stream_to: {self(), :once}, max_pipeline_size: 10, max_sessions: 10], 
                  timeout:  Application.get_env(:meshblu_performance_tools, :timeout)] do
        %HTTPotion.AsyncResponse{id: id} ->
          async_loop(id)
          {:noreply, state}
        _ ->
          
          {:noreply, state}
    end
  end

  def async_loop(id) do
    :ibrowse.stream_next(id)
    receive do
      {:ibrowse_async_headers, ^id, '200', headers} ->
        IO.inspect headers
        async_loop(id)
      {:ibrowse_async_headers, ^id, status_code, _headers} ->
        IO.inspect status_code
        async_loop(id)
      {:ibrowse_async_response_timeout, ^id} ->
        IO.inspect "timeout"
        :timeout
      {:error, :connection_closed_no_retry} ->
        IO.inspect "error"
        :error
      {:ibrowse_async_response, ^id, data} ->
        IO.inspect data
        async_loop(id)
      {:ibrowse_async_response_end, ^id} ->
        IO.inspect "end"
        async_loop(id)
    end
  end

end