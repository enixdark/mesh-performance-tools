
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
          switches: [from: :integer, to: :integer, force: :boolean, mode: :string, logpath: :string , concurrency: :integer, max_connection: :integer, delay: :integer, host: :string, port: :string, protocol: :string],
          aliases: [f: :force, m: :mode, l: :logpath , c: :concurrency, n: :max_connection, d: :delay, u: :uri, H: :host, p: :port, P: :protocol, F: :from, T: :to],
        )
        
        case parse do
          {[], _, _} -> process(:help)
          {opts, _, non_opts} -> 
            
            first = args |> Enum.find_index &(Regex.match?(~r/(-m|--mode)/, &1) ) 
            data = args |> Enum.slice(first..first+2)
                        |> Enum.at(-1)
            check = data |> (&(Regex.match?(~r/(-f$|--force$|--logpath$|-l$|-n$|--max_connection$|--delay$|-d$|-P$|--protocol$|-c$|--concurrency$|-H$|--host$|-p$|--port$)/, &1))).()

            if data != "unique" && String.to_atom(Dict.get(opts,:mode,"")) in [:unique, :file, :db_url] && !check do
              case String.to_atom(Dict.get(opts,:mode,"")) do
                :unique -> 
                  [uuid, token] = data |> String.split ":"
                  opts |> process_parse([%{uuid: uuid, token: token}])
                :file -> 
                  unless(check_from_to?(data,  Dict.get(opts,:from, nil) || 1, Dict.get(opts,:to, nil) 
                                                                               || Dict.get(opts,:max_connection, nil)  
                                                                               || Application.get_env(:meshblu_performance_tools, :max_connection)), do: process(:help))
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
        from = Dict.get(opts,:from, nil)
        to = Dict.get(opts,:to, nil)
        mode = case Dict.get(opts,:force, false) do
          true -> :multi
          _ -> :once    
        end
        load_config = nil
        uri = case title do
          :mqtt ->  
            load_config =  URI.parse(Application.get_env(:meshblu_performance_tools, :mqtt_uri))
            URI.parse(Dict.get(opts,:host, nil) || Application.get_env(:meshblu_performance_tools, :mqtt_uri))
          _ ->  
            load_config = URI.parse(Application.get_env(:meshblu_performance_tools, :uri))
            URI.parse(Dict.get(opts,:host, nil) || Application.get_env(:meshblu_performance_tools, :uri))
        end
        
        
        host = uri.host || uri.path || load_config.host
        port = Dict.get(opts,:port, nil)  || uri.port || load_config.port
        protocol = Dict.get(opts,:protocol, nil)  || uri.scheme || load_config.scheme
        :ibrowse.set_max_sessions("#{protocol}://#{host}", port, Application.get_env(:meshblu_performance_tools, :ibrowse_max_connection))
        process(Keyword.merge([concurrency: Dict.get(opts,:concurrency, nil) || Application.get_env(:meshblu_performance_tools, :concurrency), 
                                            max_connection: to || Dict.get(opts,:max_connection, nil)  || Application.get_env(:meshblu_performance_tools, :max_connection), 
                                            delay: Dict.get(opts,:delay, nil) || Application.get_env(:meshblu_performance_tools, :delay), 
                                            uri: "#{protocol}://#{host}:#{port}",
                                            level: mode],
                                            Dict.drop(opts,[:from, :to, :host, :port, :logpath, :protocol]) ) |> Enum.sort, Enum.to_list(data), 
                                            if( String.to_atom(Dict.get(opts,:mode,"")) == :file, do: from || 1, else: 1) , 
                                            Enum.to_list(data))
      end

      defp check_from_to?(file, from, to) do
        {:ok, json} = File.read file
        body = Poison.decode! json
        count = Enum.count body["devices"]
        cond do
          (from != nil and to != nil) and (from > to) ->
            IO.puts "  Can't process so start size is large than end size\n"
            :false
          from > count || from < 0 ->
            IO.puts "  Can't process so start of size is out of data size\n"
            :false
          to > count || to < 0 -> 
            IO.puts "  Can't process so end of size is large than data size\n"
            :false 
          true ->
            :true
        end
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
            -H, --host   request to hostname of meshblu service . Default: localhost
            -p, --port   request to port of meshblu service . Default: 3000 for http, 1883 for mqtt
            -P, --protocol   protocol of meshblu service . Default: http
            -f, --force  use for mode, to force a request indepent
            -F, --from   position of start of data in file
            -T, --to     position of end of data in file
            -l, --logpath      path to save log
        """
        System.halt(0)
      end


      defp process(_) do
        ""
      end

      # defp loop() do
      #   report
      #   :timer.sleep(Application.get_env(:meshblu_performance_tools, :loop_time))
      #   loop()
      # end

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


      defoverridable [loop: 0, parse_args: 1, process: 1, process: 4, run: 1, title: 0, process_parse: 2, handle_event: 3]
    end
  end

  
end