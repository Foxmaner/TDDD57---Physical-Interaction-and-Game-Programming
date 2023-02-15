extends Node2D
var client = WebSocketClient.new()
var url = "ws://localhost:5000"

onready var interpreter = get_node("BodyInterpreter")

func _ready():
	client.connect("data_received", self, "_on_data_recieved")
	
	var err = client.connect_to_url(url)
	if err != OK:
		set_process(false)
		print("Unable to connect")
		
func _process(_delta):
	client.poll()
	print(interpreter.tiltHead)

func _on_data_recieved(): 
	var payload = client.get_peer(1).get_packet().get_string_from_utf8()
	var dict = JSON.parse(payload)
	
	interpreter.interpretData(dict)
	
