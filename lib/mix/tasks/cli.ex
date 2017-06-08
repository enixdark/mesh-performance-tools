require IEx;

defmodule Mix.Tasks.Cli do
  use Mix.Task
  require Logger

  @shortdoc "return cli"
  defp parse_args(args) do
    parse = args 
    |> OptionParser.parse(
      switches: [logpath: :string , concurrency: :integer, max_connection: :integer, delay: :integer, host: :string, port: :string, protocol: :string],
      aliases: [l: :logpath , c: :concurrency, n: :max_connection, d: :delay, u: :uri, s: :stream_uri, h: :host, p: :port, P: :protocol],
    )
    case parse do
      {opts, [protocol | argv ], opts_without_parse} -> 
        full_opts = (opts |> Enum.map(fn({k,v}) ->  "--#{k} #{v}"  end)) ++ (opts_without_parse |> Enum.map(fn({k,v}) ->  "#{k} #{v}"  end))
        |> Enum.join(" ")
        case protocol do
          "http" -> 
            "mix http #{full_opts}" |> Mix.shell.cmd #String.to_char_list |> :os.cmd
            :ok
          "mqtt" -> 
             "mix mqtt #{full_opts}" |> Mix.shell.cmd
            :ok
          _ -> process(:help)
        end
      {_, _, _} -> process(:help)
      
    end
  end


  defp process(:help) do
    IO.puts """
      Cli tool to test performance for meshblu, select between http and mqtt
      Options:
        -c, --concurrency  Number of concurrent requests. Default: 1
        -n, --max_connection        Max number of total requests. Default: 10
        -d, --delay        Delay time for every request. Default: 1
        -h, --host   request to hostname of meshblu service . Default: localhost
        -p, --port   request to port of meshblu service . Default: 3000
        -s, --protocol   protocol of meshblu service . Default: 3000
        -l, --logpath      path to save log
    """
    System.halt(0)
  end

  def run(args) do
    Process.flag(:trap_exit, true)
    args 
    |> parse_args 
    |> process
  end

end