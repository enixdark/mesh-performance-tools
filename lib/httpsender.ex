defmodule HTTPSender do
  require IEx
  def send_request(request) do
    case HTTPotion.get request, [headers: ["meshblu_auth_uuid": "07d0fda7-2972-4aa7-b9d1-1c7e95adfe2f", "meshblu_auth_token": "ac17b5b772a1585df7fd61ff9bd6660cbbc7df0c"], 
      ibrowse: [stream_to: {self(), :once}], timeout: 1000_000] do
        %HTTPotion.AsyncResponse{id: id} -> 
          async_loop(id)
      {:error, :unknown_req_id} ->
        :error 
    end
  end

  defp async_loop(id) do
    :ibrowse.stream_next(id)
    receive do
      {:ibrowse_async_headers, ^id, '200', headers} ->
        async_loop(id)
      {:ibrowse_async_headers, ^id, status_code, _headers} ->
        async_loop(id)
      {:ibrowse_async_response_timeout, ^id} ->
        :timeout
      {:error, :connection_closed_no_retry} ->
        :error
      {:ibrowse_async_response, ^id, data} ->
        IO.puts data
        async_loop(id)
      {:ibrowse_async_response_end, ^id} ->
        :end
    end
  end

  
  # def receive_request do
  #   Task.start_link(fn -> loop end)
  # end
  
  # defp loop do
    
  #   receive do
  #     %HTTPotion.AsyncHeaders{status_code: status_code} -> 
  #       IEx.pry
  #       IO.puts Integer.to_string(status_code)
  #       loop
  #     %HTTPotion.AsyncChunk{chunk: chunk} -> 
  #       IEx.pry
  #       IO.puts chunk
  #       loop
  #     %HTTPotion.AsyncEnd{} ->
  #       IEx.pry
  #       IO.puts "End !"
  #     HTTP -> 
  #       IEx.pry
  #       loop
  #   end
  # end
end
