defmodule MeshbluPerformanceTools do
  use Application
  require Logger
  @moduledoc """
  Documentation for MeshbluPerformanceTools.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.info "start workers....................."
    children = [
      # Define workers and child supervisors to be supervised
        :hackney_pool.child_spec(:first_pool,  [timeout: Application.get_env(:meshblu_performance_tools, :timeout), 
                                                max_connections: Application.get_env(:meshblu_performance_tools, :max_connection)]),
        :poolboy.child_spec(pool(:tools), poolboy_config(MeshbluPerformanceTools.Tools.Register, :tools,1),[]),
    ]
    opts = [strategy: :one_for_one, name: MeshbluPerformanceTools.Supervisor]
    Supervisor.start_link(children, opts)
   end

   def pool(name), do: String.to_atom("pool_#{name}")

   defp poolboy_config(module,name,size) do
     [
       {:name, {:local, pool(name)}},
       {:worker_module, module},
       {:size, size},
       {:max_overflow, 5}
     ]
   end
end
