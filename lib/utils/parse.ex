defmodule Parser do

  def ini_parse(file) do
    
    test = File.read(file) 
    |> elem(1)
    |> String.split("\n")
    |> Stream.filter(&String.contains?(&1, "="))
    |> Stream.map(
      fn line ->
        [key, value] = String.split(line, "=")
        key = String.strip(key) |> String.to_atom
        {key, String.strip(value)}
      end)
    |> Enum.chunk(3)
    |> Stream.map( fn [id: _, uuid: uuid, token: token] ->
       %{
         uuid: uuid,
         token: token
       } 
      end)
  end

  def json_parse(file) do
    %{"devices" => list} = File.read(file) |> elem(1)
                                           |> Poison.decode!
    list |> Stream.map(&(%{
      uuid: &1["uuid"], 
      token: &1["token"]
    }))
  end

  def csv_parse(file) do
    NimbleCSV.define(CSVParser, separator: ",", escape: "\"s")
    file |> File.stream!
         |> CSVParser.parse_stream
         |> Stream.map( fn [_, uuid, token] -> %{uuid: uuid, token: token} end)        
  end

  def yaml_parse(file) do
    [[{_, list}]] = :yamerl_constr.file(file)
    list |> Stream.map( fn [{_,_}, {_, uuid}, {_, token}] ->
      %{
        uuid: uuid,
        token: token
      }
    end)
  end

  def db_parse(uri) do
    :ok
  end

end