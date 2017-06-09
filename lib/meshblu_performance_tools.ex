defmodule MeshbluPerformanceTools do
  use Application
  require Logger
  @moduledoc """
  Documentation for MeshbluPerformanceTools.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.info "start workers....................."
    :ibrowse.set_max_sessions("http://ads-elb-external-1267527463.ap-southeast-1.elb.amazonaws.com", 3000, 10000)
    :ibrowse.set_max_sessions("http://ads-elb-external-1267527463.ap-southeast-1.elb.amazonaws.com", 3001, 10000)
    :ibrowse.set_max_pipeline_size("http://ads-elb-external-1267527463.ap-southeast-1.elb.amazonaws.com", 3000, 10000)
    :ibrowse.set_max_pipeline_size("http://ads-elb-external-1267527463.ap-southeast-1.elb.amazonaws.com", 3001, 10000)

    children = [
        # Define workers and child supervisors to be supervised
        #  :hackney_pool.child_spec(:first_pool,  [timeout: Application.get_env(:meshblu_performance_tools, :timeout), 
        #                                         max_connections: Application.get_env(:meshblu_performance_tools, :max_connection)]),
         :poolboy.child_spec(:register, poolboy_config(MeshbluPerformanceTools.HTTP.Register, :http,  10000),[]),
         :poolboy.child_spec(:client, poolboy_config(MeshbluPerformanceTools.MQTT.Client, :client,  1), 
          [host: "localhost", port: 1883, uuid: "47706d7d-a6db-4edd-b7a1-f7aebc5bef4e", token: "e6869b631aa3d521a842752f8ed7300d62fa9332"]),
    ]
    opts = [strategy: :one_for_one, name: MeshbluPerformanceTools.Supervisor]
    Supervisor.start_link(children, opts)
   end

   def pool(name), do: String.to_atom("pool_#{name}")

   defp poolboy_config(module,name,size) do
     [
       {:name, {:local, name}},
       {:worker_module, module},
       {:size, size},
       {:max_overflow, 5}
     ]
   end
end
