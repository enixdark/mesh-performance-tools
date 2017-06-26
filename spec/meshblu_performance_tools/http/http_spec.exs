defmodule HTTPSpec do
  use ESpec
  require Logger
  import Mock


  before_all do

    
  end

  after_all do
  end

  context "test register service with http" do
    it "should return state with uuid and token after call register uri" do
      with_mock(HTTPotion, [post: fn("http://localhost:3000/devices") -> 
         %HTTPotion.Response{
           body: "{'uuid':'e0492a4d-bb6e-4982-8568-8b59d1183d0b','token':'f646b87db166ba7405152f6b5ae1f0c8612fee3f','timestamp':'2017-06-13T09:22:32.282Z','sendWhitelist':['*'],'receiveWhitelist':['*'],'protocol':'http:','port':'3000','online':false,'message':'','meshblu':{'hash':'InRwxBEWzippz0qUxLrjYiK1dgL6DTCwMm2xvpU6uj4=','createdAt':'2017-06-13T09:22:32.219Z'},'level':'info','host':'localhost','discoverWhitelist':['*'],'configureWhitelist':['*'],'_id':'593faed81ac0d962446ab9c1'}"} 
          end]) do
            {:ok, pid} = MeshbluPerformanceTools.HTTP.Register.start_link []
            MeshbluPerformanceTools.HTTP.Register.register({pid,"http://localhost:3000/devices", %{}})
      end
    end

    it "should return state with uuid and token after call register uri1" do

      # allow(HTTPotion).to accept(:spawn_worker_proces, fn(_url) -> {:ok, "<1.1.1>"} end)

      # with_mock(HTTPotion, [get: fn("http://localhost:3000/subscribe") -> 
      #       %HTTPotion.AsyncResponse{id: "1"}
      #     end]) do
      #       {:ok, pid} = MeshbluPerformanceTools.HTTP.Register.start_link []
      #       MeshbluPerformanceTools.HTTP.Register.subscriber(pid, "http://localhost:3000", 
      #       "e0492a4d-bb6e-4982-8568-8b59d1183d0b", "f646b87db166ba7405152f6b5ae1f0c8612fee3f")
      # end
      
    end
  end  
end