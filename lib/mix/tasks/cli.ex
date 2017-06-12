require IEx;
defmodule Mix.Tasks.Cli do
  use Mix.Task
  require Logger

  @shortdoc "return cli"
  defp parse_args(args) do
    parse = args 
    |> OptionParser.parse(
        switches: [force: :boolean, mode: :string, logpath: :string , concurrency: :integer, max_connection: :integer, delay: :integer, host: :string, port: :string, protocol: :string],
        aliases: [f: :force, m: :mode, l: :logpath , c: :concurrency, n: :max_connection, d: :delay, u: :uri, H: :host, p: :port, P: :protocol],
    )
    case parse do
      {opts, [protocol | argv ], opts_without_parse} -> 

        first = args |> Enum.find_index &(Regex.match?(~r/(-m|--mode)/, &1) ) 
        data = args |> Enum.slice(first..first+2)
                    |> Enum.at(-1)
        check = data |> (&(Regex.match?(~r/(-f|--force|--logpath|-l|-n|--max_connection|--delay|-d|-P|--protocol|-c|--concurrency|-H|--host|-p|--port)/, &1))).()
        full_opts = (opts |> Enum.map(fn({k,v}) ->
          if(k == :m || k == :mode) do
            "--#{k} #{v} #{data}"
          else
            "--#{k} #{v}"
          end
        end)) ++ (opts_without_parse |> Enum.map(fn({k,v}) ->  "#{k} #{v}"  end))
        |> Enum.join(" ")
        case protocol do
          "http" -> 
            "mix http #{full_opts}" |> Shell.shell
            :ok
          "mqtt" -> 
             "mix mqtt #{full_opts}" |> Shell.shell
            :ok
          _ -> process(:help)
        end
      {_, _, _} -> process(:help)
      
    end
  end


  defp process(:help) do
    IO.puts """
      Cli tool to test performance for meshblu, select between http and mqtt
      Example:
        http [optionals]
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
    
  end

  def run(args) do
    Process.flag(:trap_exit, true)
    args 
    |> parse_args 
    |> process
  end

end