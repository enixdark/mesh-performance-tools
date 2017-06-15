defmodule MeshbluPerformanceTools.HTTP.Process do
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

  def subscriber(pid, uuid, token) do
    GenServer.cast(pid, {:subscribe, uuid, token})
  end


  @doc """
  event subscriber via http streaming
  """
  def handle_cast({:subscribe, uuid, token}, state) do
    :ibrowse.set_max_sessions("http://#{state[:host]}", state[:port], 10000)
    {:ok, worker_pid} = HTTPotion.spawn_worker_process("http://#{state[:host]}:#{state[:port]}/subscribe")
     case HTTPotion.get "http://#{state[:host]}:#{state[:port]}/subscribe", [headers: ["meshblu_auth_uuid": uuid, "meshblu_auth_token": token],
        ibrowse: [direct: worker_pid, stream_to: {self(), :once}, max_pipeline_size: 10000, max_sessions: 10000], 
                  timeout:  2_000_000] do
        %HTTPotion.AsyncResponse{id: id} ->
          Logger.info "#{uuid} with pid #{:erlang.pid_to_list self()} subscribed"
          async_loop(id, uuid)
          {:noreply, state}
        _ ->
          {:noreply, state}
    end
  end

  @doc """
  listen a http stream when a client request 
  a subscribe connection to meshblu server 
  """
  def async_loop(id, uuid) do
    # :ibrowse.stream_next(id)
    receive do
      {:ibrowse_async_headers, ^id, '200', headers} ->
        # IO.inspect headers
        async_loop(id, uuid)
      {:ibrowse_async_headers, ^id, status_code, _headers} ->
        # IO.inspect status_code
        async_loop(id, uuid)
      {:ibrowse_async_response_timeout, ^id} ->
        Logger.error "device with #{uuid} has timeout"
        :timeout
        # async_loop(id)
      {:error, :connection_closed_no_retry} ->
        Logger.error "device with #{uuid} connection closed"
        :error
        # async_loop(id)
      {:ibrowse_async_response, ^id, data} ->
        Logger.info "#{uuid} - #{:erlang.pid_to_list self()} received #{inspect(data)}"
        # IO.inspect data
        async_loop(id, uuid)
      {:ibrowse_async_response_end, ^id} ->
        Logger.info "response end, #{uuid} with the process #{:erlang.pid_to_list self()} exit"
        # async_loop(id)
    end
  end

end