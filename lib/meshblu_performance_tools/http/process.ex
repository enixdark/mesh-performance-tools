defmodule MeshbluPerformanceTools.HTTP.Process do
  use GenServer
  # require Timex
  require Logger
  
  def start_link(args) do
    GenServer.start_link(__MODULE__,args, [])
  end

  def init(args) do
    {:ok, %{protocal: args[:protocal], host: args[:host], port: args[:port]}}
  end

  def subscriber(pid, uuid, token) do
    GenServer.cast(pid, {:subscribe, uuid, token})
  end

  def handle_cast({:subscribe, uuid, token}, state) do
    :ibrowse.set_max_sessions("http://#{state[:host]}", state[:port], 10000)
    {:ok, worker_pid} = HTTPotion.spawn_worker_process("http://#{state[:host]}:#{state[:port]}/subscribe")
     case HTTPotion.get "http://#{state[:host]}:#{state[:port]}/subscribe", [headers: ["meshblu_auth_uuid": uuid, "meshblu_auth_token": token],
        ibrowse: [direct: worker_pid, stream_to: {self(), :once}, max_pipeline_size: 10000, max_sessions: 10000], 
                  timeout:  2_000_000] do
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
        # IO.inspect headers
        async_loop(id)
      {:ibrowse_async_headers, ^id, status_code, _headers} ->
        # IO.inspect status_code
        async_loop(id)
      {:ibrowse_async_response_timeout, ^id} ->
        Logger.error "timeout"
        :timeout
        # async_loop(id)
      {:error, :connection_closed_no_retry} ->
        Logger.error "error"
        :error
        # async_loop(id)
      {:ibrowse_async_response, ^id, data} ->
        Logger.info inspect(self())
        # IO.inspect data
        async_loop(id)
      {:ibrowse_async_response_end, ^id} ->
        Logger.info "response end, the process exit #{:erlang.pid_to_list self()}"
        # async_loop(id)
    end
  end

end