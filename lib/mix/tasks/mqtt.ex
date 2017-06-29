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


end


