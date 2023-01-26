extends Control

var client = WebSocketClient.new()
var url = "ws://localhost:5000"
onready var handIcon = $Sprite

func _ready():
	client.connect("data_received", self, "_on_data_recieved")
	
	var err = client.connect_to_url(url)
	if err != OK:
		set_process(false)
		print("Unable to connect")
		
func _process(_delta):
	client.poll()
	
var dict = null

func isHandClosed(handData):
	var middleFingerTop = handData[12]
	var middleFingerRoot = handData[9]
	
	if(middleFingerTop["y"]>middleFingerRoot["y"]):
		return true
	else:
		return false

func getHandPositionRelative(x,y):
	return Vector2(x*get_viewport().size.x,y*get_viewport().size.y)


func _on_data_recieved(): 
	var payload = client.get_peer(1).get_packet().get_string_from_utf8()
	var dict = JSON.parse(payload)
	#Depending on the dict, the TYPE: varable will be FACE_DETECT, FACE_TRACK, POSE, HANDS and then the data will be in "DATA" key
	#e.g. dict.DATA == "FACE_TRACK"
	$TextEdit2.text = str(dict.result["DATA"]["landmark"][1])
	
	var handposition = getHandPositionRelative(dict.result["DATA"]["landmark"][1]["x"],dict.result["DATA"]["landmark"][1]["y"])
	
	
	handIcon.position = handposition
	
	if(isHandClosed(dict.result["DATA"]["landmark"])):
		handIcon.modulate = Color(0,0,1)
	else:
		handIcon.modulate = Color(1,1,1)
	
	
	
	
func send(data): 
	client.get_peer(1).put_packet(JSON.print(data).to_utf8())


func _on_Button_pressed():
	send($TextEdit.text)
	
