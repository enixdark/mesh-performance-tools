defmodule MeshbluPerformanceTools.HTTP.Process do
  use GenServer
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
    
    {:ok, worker_pid} = HTTPotion.spawn_worker_process("http://#{state[:host]}:#{state[:port]}/subscribe")
    case HTTPotion.get "http://#{state[:host]}:#{state[:port]}/subscribe", [headers: ["meshblu_auth_uuid": uuid, "meshblu_auth_token": token],
        ibrowse: [direct: worker_pid, stream_to: {self(), :once}, max_pipeline_size: Application.get_env(:meshblu_performance_tools, :ibrowse_max_connection), 
                                                                  max_sessions: Application.get_env(:meshblu_performance_tools, :ibrowse_max_connection)], 
                  timeout:  2_000_000] do
        %HTTPotion.AsyncResponse{id: id} ->
          Logger.info Poison.encode! %{uuid: uuid, pid: :erlang.pid_to_list(self()), type: :subscribe, token: token, time: System.system_time(:millisecond)}
          async_loop(id, uuid)
          {:noreply, state}
        error ->
          Logger.info Poison.encode! %{uuid: uuid, pid: :erlang.pid_to_list(self()), type: :terminated, token: token, reason: error, time: System.system_time(:millisecond)}
          {:noreply, state}
    end
  end

  @doc """
  listen a http stream when a client request 
  a subscribe connection to meshblu server 
  """
  def async_loop(id, uuid) do
    :ibrowse.stream_next(id)
    receive do
      {:ibrowse_async_headers, ^id, '200', headers} ->
        Logger.info inspect(%{uuid: uuid, headers: headers, time: System.system_time(:millisecond), code: 200, type: :success})
        async_loop(id, uuid)
      {:ibrowse_async_headers, ^id, status_code, headers} ->
        Logger.info inspect(%{uuid: uuid, type: :error, time: System.system_time(:millisecond), code: status_code, headers: headers})
        async_loop(id, uuid)
      {:ibrowse_async_response_timeout, ^id} ->
        Logger.info inspect(%{uuid: uuid, time: System.system_time(:millisecond), type: :error, reason: :timeout})
        :timeout
      {:error, :connection_closed_no_retry} ->
        Logger.info inspect(%{uuid: uuid, time: System.system_time(:millisecond), type: :error, reason: :connection_closed})
        :error
      {:ibrowse_async_response, ^id, data} ->
        if data != [] do
          Logger.info inspect(%{uuid: uuid, time: System.system_time(:millisecond), type: :receive, message: inspect(data)})
        end
        async_loop(id, "#{:erlang.pid_to_list(self())} uuid")
      {:ibrowse_async_response_end, ^id} ->
        Logger.info inspect(%{uuid: uuid, time: System.system_time(:millisecond), type: :terminated})
        :ets.insert_new(:errors, {"#{:erlang.pid_to_list(self())} uuid", "504"})
    end
  end

  # def handle_info(_msg, state) do
  #   {:noreply, state}
  # end

end