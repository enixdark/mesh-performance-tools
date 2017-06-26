defmodule ParserSpec do
  use ESpec
  require Logger
  require IEx



  before_all do

    json_data = %{
                  "devices": [
                      %{
                          "token": "259f6a54f27477ffc63342d2f1614f788bd9724a", 
                          "uuid": "b37b29d6-2f62-48c8-84a5-7ea5477235db"
                      }
                  ]
                }
    {:ok, file} = File.open "temp.json", [:write]
    IO.binwrite file, Poison.encode!(json_data)

    csv_data = "id,uuid,token\n1,b37b29d6-2f62-48c8-84a5-7ea5477235db,259f6a54f27477ffc63342d2f1614f788bd9724a"
    {:ok, file} = File.open "temp.csv", [:write]
    IO.binwrite file, csv_data

    ini_data = "[devices]\nid=1\nuuid=b37b29d6-2f62-48c8-84a5-7ea5477235db\ntoken=259f6a54f27477ffc63342d2f1614f788bd9724a"
    {:ok, file} = File.open "temp.init", [:write]
    IO.binwrite file, ini_data

    yaml_data = """
    devices:
      - id: 1
        uuid: "b37b29d6-2f62-48c8-84a5-7ea5477235db"
        token: "259f6a54f27477ffc63342d2f1614f788bd9724a"

    """
    {:ok, file} = File.open "temp.yaml", [:write]
    IO.binwrite file, yaml_data
  end

  after_all do
    ["temp.json", "temp.csv", "temp.ini", "temp.yaml"] |> Enum.each( &File.rm(&1) )
  end

  defp parse(mod, func, file) do
    data = apply(mod, func, [file])
    [ %{
      "uuid": uuid,
      "token": token
    } | tail ] = data |> Enum.to_list 
    {:ok, {uuid, token}}
  end

  context "check result from output file after use parser" do
    it "test parse with file json" do
      {:ok, {uuid, token}} = parse(Parser, :json_parse, "temp.json")
      IEx.pry
      expect(uuid) |> to(eq "b37b29d6-2f62-48c8-84a5-7ea5477235db") 
      expect(token) |> to(eq "259f6a54f27477ffc63342d2f1614f788bd9724a") 
    end

    it "test parse with file csv" do
      {:ok, {uuid, token}} = parse(Parser, :csv_parse, "temp.csv")
      expect(uuid) |> to(eq "b37b29d6-2f62-48c8-84a5-7ea5477235db") 
      expect(token) |> to(eq "259f6a54f27477ffc63342d2f1614f788bd9724a") 
    end

    it "test parse with file ini" do
      {:ok, {uuid, token}} = parse(Parser, :ini_parse, "temp.init")
      expect(uuid) |> to(eq "b37b29d6-2f62-48c8-84a5-7ea5477235db") 
      expect(token) |> to(eq "259f6a54f27477ffc63342d2f1614f788bd9724a") 
    end

    it "test parse with file yaml" do
      {:ok, {uuid, token}} = parse(Parser, :yaml_parse, "temp.yaml")
      expect(uuid) |> to(eq 'b37b29d6-2f62-48c8-84a5-7ea5477235db') 
      expect(token) |> to(eq '259f6a54f27477ffc63342d2f1614f788bd9724a') 
    end
  end  
end