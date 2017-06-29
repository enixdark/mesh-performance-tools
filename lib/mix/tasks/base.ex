
defmodule Mix.Tasks.Base do
  

  #@shortdoc "return base"
  defmacro __using__(_) do
    quote do
      require Logger
      alias EctoMnesia.Table
      require IEx

      defp parse_args(args) do
        parse = args 
        |> OptionParser.parse(
          switches: [force: :boolean, mode: :string, logpath: :string , concurrency: :integer, max_connection: :integer, delay: :integer, host: :string, port: :string, protocol: :string],
          aliases: [f: :force, m: :mode, l: :logpath , c: :concurrency, n: :max_connection, d: :delay, u: :uri, H: :host, p: :port, P: :protocol],
        )
        
        case parse do
          {[], _, _} -> process(:help)
          {opts, _, non_opts} -> 

            first = args |> Enum.find_index &(Regex.match?(~r/(-m|--mode)/, &1) ) 
            data = args |> Enum.slice(first..first+2)
                        |> Enum.at(-1)
            check = data |> (&(Regex.match?(~r/(-f$|--force$|--logpath$|-l$|-n$|--max_connection$|--delay$|-d$|-P$|--protocol$|-c$|--concurrency$|-H$|--host$|-p$|--port$)/, &1))).()

            if data != "unique" && String.to_atom(Dict.get(opts,:mode,"")) in [:unique, :file, :db_url] && !check do
              # Table.insert(:meshblu, {:meshblu, :key, System.system_time(:second), 0, [], [], 0})
              :ets.new(:general, [:set, :public, {:write_concurrency, true}, {:read_concurrency, true}, :named_table])
              :ets.new(:errors, [:set, :public, {:write_concurrency, true}, {:read_concurrency, true}, :named_table])
              :ets.new(:messages, [:set, :public, {:write_concurrency, true}, {:read_concurrency, true}, :named_table])
              :ets.new(:total, [:set, :public, {:write_concurrency, true}, {:read_concurrency, true}, :named_table])
              spawn fn -> loop end
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
        uri = case title do
          :mqtt ->  URI.parse(Dict.get(opts,:host, nil) || Application.get_env(:meshblu_performance_tools, :mqtt_uri))
          _ ->  URI.parse(Dict.get(opts,:host, nil) || Application.get_env(:meshblu_performance_tools, :uri))
        end
        host = uri.host
        port = Dict.get(opts,:port, nil)  || uri.port
        protocol = Dict.get(opts,:protocol, nil)  || uri.scheme
        process(Keyword.merge([concurrency: Dict.get(opts,:concurrency, nil) || Application.get_env(:meshblu_performance_tools, :concurrency), 
                                            max_connection: Dict.get(opts,:max_connection, nil)  || Application.get_env(:meshblu_performance_tools, :max_connection), 
                                            delay: Dict.get(opts,:delay, nil) || Application.get_env(:meshblu_performance_tools, :delay), 
                                            uri: "#{protocol}://#{host}:#{port}",
                                            level: mode],
                                            Dict.drop(opts,[:host, :port, :logpath, :prorotol]) ) |> Enum.sort, Enum.to_list(data), 1, Enum.to_list(data))
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
        :base
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
        report
        :timer.sleep(1000)
        loop()
      end

      defp wait() do
        receive do
          _ -> 
            wait()
        end
      end

      def handle_event(uuid, token, options) do
        :ok
      end

      def process(opts, [head|data], count, persistent_auth) do
        case opts do
          [concurrency: concurrency, delay: delay, level: _, max_connection: max_connection, mode: :unique, uri: uri] -> 

            handle_event(head[:uuid], head[:token], opts)  
            if (rem(count, concurrency) == 0) do
              # Logger.info "### delay time at: <<#{System.system_time(:second)}>>"
              # report
              :timer.sleep(delay)    
            end
            if (count >= max_connection) do
               wait()
            end
            process(opts, data, count + 1, nil)
          [concurrency: concurrency, delay: delay, level: :once, max_connection: max_connection, mode: _, uri: uri] -> 
            handle_event(head[:uuid], head[:token], opts) 
            if rem(count, concurrency) == 0 do
              # report
              :timer.sleep(delay)    
            end                 
            if (data == [] || count == max_connection) do
              wait()
            end
            process(opts, data, count + 1, nil)
          [concurrency: concurrency, delay: delay, force: _, level: :multi, max_connection: max_connection, mode: _, uri: uri] -> 
            handle_event(head[:uuid], head[:token], opts) 
            if rem(count, concurrency) == 0 do
              # report
              :timer.sleep(delay)    
            end
            if (count >= max_connection) do 
              Logger.info "complete all request at: <<#{System.system_time(:second)}>>"
              wait()
            end
            cond do
              data == [] -> process(opts, persistent_auth, count + 1, persistent_auth)
              true -> process(opts, data, count + 1, persistent_auth)
            end
          _ ->
            :ok
        end
      end

      def run(args) do
        Process.flag(:trap_exit, true)
        Mix.Task.run "app.start", []
        args 
        |> parse_args
        |> process
      end

      def report do
        total_size = :total |> :ets.tab2list |> Enum.count
        errors = :errors |> :ets.tab2list
        error_size = errors |> Enum.count
        timeout_size = errors |> Enum.filter(fn {uuid, status_code} -> 
          status_code == "408"
        end) |> Enum.count
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
        request: total_size, errors: error_size, success: (if total_size >0, do: total_size - error_size, else: 0), messages: messages_size, timeout: timeout_size}
      end

      defoverridable [loop: 0, parse_args: 1, process: 1, process: 4, run: 1, title: 0, process_parse: 2, handle_event: 3]
    end
  end

  
end