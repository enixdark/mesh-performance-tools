# # %Hulaaki.Message.ConnAck{return_code: return_code, session_present: session_present, type: :CONNACK}, state: %{connection: #PID<0.259.0>}] = MeshbluPerformanceTools.MQTT.Process.connect(pid, options)
# alias Hulaaki.Message
# alias Hulaaki.Connection
# {:ok, pid} = MeshbluPerformanceTools.MQTT.Process.start_link(%{parent: self()})
# options = [client_id: "test", username: "47706d7d-a6db-4edd-b7a1-f7aebc5bef4e", password: "e6869b631aa3d521a842752f8ed7300d62fa9332", host: "localhost", port: 1883, timeout: 100_000]
# MeshbluPerformanceTools.MQTT.Process.connect(pid, options)

# alias Hulaaki.Message
# alias Hulaaki.Connection
# {:ok, pid} = Connection.start_link(self())
# options = [client_id: "test", username: "47706d7d-a6db-4edd-b7a1-f7aebc5bef4e", password: "e6869b631aa3d521a842752f8ed7300d62fa9332", host: "localhost", port: 1883, timeout: 100_000]
# message = Message.connect("hello", "47706d7d-a6db-4edd-b7a1-f7aebc5bef4e",  "e6869b631aa3d521a842752f8ed7300d62fa9332", "", "", 0, 0, 0, 100)
# Connection.connect(pid, message, options)
# id = :random.uniform(65_535)
# topics = ["message"]
# qoses =  [0]
# message1 = Message.subscribe(id, topics, qoses)

# Connection.subscribe(pid, message1)


# topic = "message"
# message = Poison.encode!(%{topic: "message", devices: ["47706d7d-a6db-4edd-b7a1-f7aebc5bef4e"], payload: "helo owlrd"})
# dup = 0
# qos = 0
# retain = 0
# message0 = Message.publish(topic, message, dup, qos, retain)
# Connection.publish(pid, message0)


# message = Message.subscribe(24_756, ["message"], [1])
# options_sub = [id: 24_756, topics: ["message"], qoses: [1]]
# MeshbluPerformanceTools.MQTT.Process.subscribe(pid, message)
# options_mes = [id: 24_756, topic: "message", message: Poison.encode!(%{topic: "message", devices: ["47706d7d-a6db-4edd-b7a1-f7aebc5bef4e"], payload: "helo owlrd"}) ,dup: 0, qos: 1, retain: 1, timeout: 10000]
# MeshbluPerformanceTools.MQTT.Process.publish(pid, options_mes)
# # options_mes = [id: 24_756, topic: "message", dup: 0, qos: 1, retain: 1, message: "test", username: "47706d7d-a6db-4edd-b7a1-f7aebc5bef4e", password: "e6869b631aa3d521a842752f8ed7300d62fa9332"]

# # options_mes = [id: 24_756,  topic: "hello", message: Poison.encode!(%{devices: ["47706d7d-a6db-4edd-b7a1-f7aebc5bef4e"],  payload: %{ilove: :food}, topic: "hello"}) ,dup: 0, qos: 1, retain: 1]



# # 
# # %Message.Connect{client_id: "hello", username: "47706d7d-a6db-4edd-b7a1-f7aebc5bef4e", password: "e6869b631aa3d521a842752f8ed7300d62fa9332", will_topic: "message", will_message: "message"}


# alias Hulaaki.Message
# alias Hulaaki.Connection
# {:ok, pid1} = Connection.start_link(self())
# options = [client_id: "test", username: "47706d7d-a6db-4edd-b7a1-f7aebc5bef4e", password: "e6869b631aa3d521a842752f8ed7300d62fa9332", host: "localhost", port: 1883, timeout: 100_000]
# message = Message.connect("hello", "47706d7d-a6db-4edd-b7a1-f7aebc5bef4e",  "e6869b631aa3d521a842752f8ed7300d62fa9332", "", "", 0, 0, 0, 100)
# Connection.connect(pid1, message, options)

# id = :random.uniform(65_535)
#     topics = ["qos0"]
#     qoses =  [0]
# message = Message.subscribe(id, topics, qoses)
# Connection.subscribe(pid1, message)



# topic = "qos0"
# message1 =  Poison.encode!(%{topic: "qos0", devices: ["47706d7d-a6db-4edd-b7a1-f7aebc5bef4e"], payload: "helo owlrd"})
# dup = 0
# qos = 0
# retain = 0
# message0 = Message.publish(topic, message1, dup, qos, retain)
# Connection.publish(pid1, message0)
