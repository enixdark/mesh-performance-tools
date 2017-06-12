require IEx;

defmodule Mix.Tasks.Base do

  #@shortdoc "return base"
  defmacro __using__(_) do
    quote do
      def process(opts, [head|data], count, persistent_auth) do
        "ok"
      end

      defp parse_args(args) do
        parse = args 
        |> OptionParser.parse(
          switches: [force: :boolean, mode: :string, logpath: :string , concurrency: :integer, max_connection: :integer, delay: :integer, host: :string, port: :string, protocol: :string],
          aliases: [f: :force, m: :mode, l: :logpath , c: :concurrency, n: :max_connection, d: :delay, u: :uri, s: :stream_uri, H: :host, p: :port, P: :protocol],
        )
        case parse do
          {[], _, _} -> process(:help)
          {opts, _, non_opts} -> 

            first = args |> Enum.find_index &(Regex.match?(~r/(-m|--mode)/, &1) ) 
            data = args |> Enum.slice(first..first+2)
                        |> Enum.at(-1)
            check = data |> (&(Regex.match?(~r/(-f|--force|--logpath|-l|-n|--max_connection|--delay|-d|-P|--protocol|-c|--concurrency|-H|--host|-p|--port)/, &1))).()

            if data != "unique" && String.to_atom(Dict.get(opts,:mode,"")) in [:unique, :file, :db_url] && !check do
              case String.to_atom(Dict.get(opts,:mode,"")) do
                :unique -> 
                  [uuid, token] = data |> String.split ":"
                  opts |> process_parse([%{uuid: uuid, token: token}])

                :file -> 
                  clean_data = case detect_format_file(data) do
                    :json -> 
                      Parser.json_parse data
                    :yaml ->
                      Parser.yaml_parse data
                    :csv ->
                      Parser.csv_parse data
                    :ini ->
                      Parser.ini_parse data
                  end
                  process_parse(opts, clean_data)
                :db_uri -> 
                  process_parse(opts, data)
                _ -> 
                  process(:mode)
              end
            else
              process(:mode)
            end
          _ -> process(:help)
        end
      end

      defp process_parse(opts, data) do
        mode = case Dict.get(opts,:force, false) do
          true -> :multi
          _ -> :once    
        end
        uri = URI.parse(Dict.get(opts,:host, nil) || Application.get_env(:meshblu_performance_tools, :uri))
        host = uri.host
        port = Dict.get(opts,:port, nil)  || uri.port
        protocol = Dict.get(opts,:protocol, nil)  || uri.scheme
        process(Keyword.merge([concurrency: Dict.get(opts,:concurrency, nil) || Application.get_env(:meshblu_performance_tools, :concurrency), 
                                            max_connection: Dict.get(opts,:max_connection, nil)  || Application.get_env(:meshblu_performance_tools, :max_connection), 
                                            delay: Dict.get(opts,:delay, nil) || Application.get_env(:meshblu_performance_tools, :delay), 
                                            uri: "#{protocol}://#{host}:#{port}",
                                            level: mode],
                                            opts) |> Enum.sort, Enum.to_list(data), 0, Enum.to_list(data))
      end

  
      defp detect_format_file(file) do
        #Regex.match?(~r/.json$|.csv$|.yaml$|.ini$/,file)
        cond do
          Regex.match?(~r/.json$/, file) -> :json
          Regex.match?(~r/.csv$/, file) -> :csv
          Regex.match?(~r/.ini$/, file) -> :ini
          Regex.match?(~r/.yaml$/, file) -> :yaml
          true -> :format_error
        end
      end

      def title do
        "base"
      end

      defp process(:mode) do
        IO.puts """
          Please use mode options with structure
            
            http [mode] [string|file|data_uri]

          for mode:
            
            unique|file|database

            unique: use a string with uuid:token
            file: a path string 
            database: uri of database 

          example:

            http mode unique username:password

        """

        System.halt(0)
      end

      defp process(:help) do
        IO.puts """
          Cli tool to test performance for meshblu #{title()}

          Options:
            -c, --concurrency  Number of concurrent requests. Default: 1
            -n, --max_connection        Max number of total requests. Default: 10
            -d, --delay        Delay time for every request. Default: 1
            -m, --mode   mode to use for auth devices, include single, file, database 
            -h, --host   request to hostname of meshblu service . Default: localhost
            -p, --port   request to port of meshblu service . Default: 3000 for http, 1883 for mqtt
            -P, --protocol   protocol of meshblu service . Default: http
            -f, --force  use for mode, to force a request indepent
            -l, --logpath      path to save log
        """
        System.halt(0)
      end


      defp process(_) do
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

      defoverridable [parse_args: 1, process: 1, process: 4, run: 1, title: 0, process_parse: 2]
    end
  end
end