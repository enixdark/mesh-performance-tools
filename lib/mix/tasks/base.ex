require IEx;

defmodule Mix.Tasks.Base do

  #@shortdoc "return base"
  defmacro __using__(_) do
    quote do
      
      defp parse_args(args) do
        parse = args 
        |> OptionParser.parse(
          switches: [logpath: :string , concurrency: :integer, max_connection: :integer, delay: :integer, host: :string, port: :string, protocol: :string],
          aliases: [l: :logpath , c: :concurrency, n: :max_connection, d: :delay, u: :uri, s: :stream_uri, h: :host, p: :port, P: :protocol],
        )

        case parse do
          {[], _, _} -> process(:help)
          {opts, _, _} -> 
            uri = URI.parse(Dict.get(opts,:host, nil) || Application.get_env(:meshblu_performance_tools, :uri))
            host = uri.host
            port = Dict.get(opts,:port, nil)  || uri.port
            protocol = Dict.get(opts,:protocol, nil)  || uri.scheme
            process(Keyword.merge([concurrency: Dict.get(opts,:concurrency, nil) || Application.get_env(:meshblu_performance_tools, :concurrency), 
                                                max_connection: Dict.get(opts,:max_connection, nil)  || Application.get_env(:meshblu_performance_tools, :max_connection), 
                                                delay: Dict.get(opts,:delay, nil) || Application.get_env(:meshblu_performance_tools, :delay), 
                                                uri: "#{protocol}://#{host}:#{port}"], 
                                                opts) |> Enum.sort)
                                                
          
        end
      end


      defp process(:help) do
        IO.puts """
        """
        System.halt(0)
      end

      defp process(opts) do
        ""
      end

      defp loop() do
        receive do
          _ -> loop()
        end
      end


      def run(args) do
        Process.flag(:trap_exit, true)
        Mix.Task.run "app.start", []
        args 
        |> parse_args 
        |> process
      end

      defoverridable [parse_args: 1, process: 1, run: 1]

    end
  end

end