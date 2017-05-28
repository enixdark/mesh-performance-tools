defmodule MeshbluPerformanceTools.Tools.Const do

  @moduledoc """
    define all const varaible to use in

  """

  # import Constants
  
  # const :VERSION_2, %{ meshblu: %{ version: '2.0.0', whitelists: %{} } }
  # const :DEVICE_URI, "#{System.get_env("MESHBLU_URI") || "localhost:3000"}/devices"
  # use Constants
  def version_2, do: %{ meshblu: %{ version: '2.0.0', whitelists: %{} } }
  def device_uri, do: "#{System.get_env("MESHBLU_URI") || "http://localhost:3000"}/devices"
end