extends Control

var client = WebSocketClient.new()
var url = "ws://localhost:5000"

func _ready():
	client.connect("data_received", self, "_on_data_recieved")
	
	var err = client.connect_to_url(url)
	if err != OK:
		set_process(false)
		print("Unable to connect")
		
func _process(_delta):
	client.poll()
	
var dict = null
func _on_data_recieved(): 
	var payload = client.get_peer(1).get_packet().get_string_from_utf8()
	var dict = JSON.parse(payload)
	#Depending on the dict, the TYPE: varable will be FACE_DETECT, FACE_TRACK, POSE, HANDS and then the data will be in "DATA" key
	#e.g. dict.DATA == "FACE_TRACK"
	$TextEdit2.text = str(dict.result)
	
	
func send(data): 
	client.get_peer(1).put_packet(JSON.print(data).to_utf8())


func _on_Button_pressed():
	send($TextEdit.text)
	
