defmodule Mix.Tasks.Http do
  use Mix.Task
  use Mix.Tasks.Base
  alias EctoMnesia.Table
  require IEx
  @shortdoc "return http"
  def title do
    :http
  end

  def handle_event(uuid, token, options) do
    {:ok, pid} = MeshbluPerformanceTools.HTTP.Register.start_link([])
    MeshbluPerformanceTools.HTTP.Register.subscriber(pid, options[:uri], uuid, token)
  end

end