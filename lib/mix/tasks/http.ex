require IEx;

defmodule Mix.Tasks.Http do
  use Mix.Task
  use Mix.Tasks.Base

  @shortdoc "return http"
  def title do
    :http
  end

  defp handle_even(uuid, token, options) do
    :poolboy.transaction(:http,
                          fn(id) -> 
                            MeshbluPerformanceTools.HTTP.Register.subscriber(id, options[:uri], uuid, token)
                          end,options[:delay])
  end

end