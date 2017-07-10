defmodule MeshbluPerformanceTools.MQTT.Supervisor do
  use Supervisor
  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(MeshbluPerformanceTools.MQTT.Process, [])
    ]
 
    supervise(children, [strategy: :one_for_one])
  end

  def create_user(id), do: Supervisor.start_child(__MODULE__, [id])
end