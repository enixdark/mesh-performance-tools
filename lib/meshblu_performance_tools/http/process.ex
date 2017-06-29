defmodule MeshbluPerformanceTools.HTTP.Process do
  use GenServer
  # require Timex
  require Logger
  alias EctoMnesia.Table

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
          # Logger.info "#{uuid} with pid #{:erlang.pid_to_list self()} subscribed"
          :ets.insert(:total, {uuid})
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
    :ibrowse.stream_next(id)
    receive do
      {:ibrowse_async_headers, ^id, '200', headers} ->
        # IO.inspect headers
        async_loop(id, uuid)
      {:ibrowse_async_headers, ^id, status_code, _headers} ->
        cond do
           Regex.match?(~r/^(4\d+|5\d+)/, status_code |> List.to_string ) -> 
             :ets.insert_new(:errors, {uuid, status_code |> List.to_string})
        end
        # IO.inspect status_code
        async_loop(id, uuid)
      {:ibrowse_async_response_timeout, ^id} ->
        # Logger.error "device with #{uuid} has timeout"
        :ets.insert_new(:errors, {uuid, "403"})
        :timeout
        # async_loop(id)
      {:error, :connection_closed_no_retry} ->
        # Logger.error "device with #{uuid} connection closed"
        :ets.insert_new(:errors, {uuid, "444"})
        :error
        # async_loop(id)
      {:ibrowse_async_response, ^id, data} ->
        if data != [] do
          :ets.insert(:messages, {true})
          # Logger.info "#{uuid} - #{:erlang.pid_to_list self()} received #{inspect(data)}"
        end
        :ets.insert_new(:errors, {uuid})
        async_loop(id, uuid)
      {:ibrowse_async_response_end, ^id} ->
        # Logger.info "response end, #{uuid} with the process #{:erlang.pid_to_list self()} exit"
        :ets.insert_new(:errors, {uuid, "504"})
    end
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end