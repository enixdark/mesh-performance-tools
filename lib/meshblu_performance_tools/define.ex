{:ok, p} = MeshbluPerformanceTools.Tools.Register.start_link
MeshbluPerformanceTools.Tools.Register.register(p)

# {:ok, pid} = HTTPSender.receive_request
# HTTPSender.send_request("", pid)