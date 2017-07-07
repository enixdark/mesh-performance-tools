defmodule Mix.Tasks.Mqtt do
  use Mix.Task
  use Mix.Tasks.Base
  @shortdoc "return mqtt"

  def title do
    :mqtt
  end

  def handle_event(uuid, token, options) do
    {:ok, pid} =  MeshbluPerformanceTools.MQTT.Client.start_link
    MeshbluPerformanceTools.MQTT.Client.subscriber(pid, options[:uri], uuid, token)     
  end

  def report do
    total_size = :total |> :ets.tab2list |> Enum.count
    errors = :errors |> :ets.tab2list
    error_size = errors |> Enum.count
    # timeout_size = errors |> Enum.filter(fn {uuid, status_code} -> 
    #   status_code == "408"
    # end) |> Enum.count
    messages_size = :messages |> :ets.tab2list |> Enum.count

    case :ets.tab2list(:general) do
      [] -> :ets.insert(:general, {total_size, error_size})
      [{total, error}] -> 
        :ets.delete_all_objects :general
        :ets.insert(:general, { total + total_size, error + error_size })
    end
    :ets.delete_all_objects :messages
    :ets.delete_all_objects :total
    :ets.delete_all_objects :errors
    [{total, error}] = :ets.tab2list(:general) 
    Logger.info Poison.encode! %{total_request: total, total_error: error, total_connecting: total - error, 
    request: total_size, errors: error_size, success: (if total_size >0, do: total_size - error_size, else: 0), messages: messages_size, timeout: 0}
  end


end


