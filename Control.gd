extends Control

var client = WebSocketClient.new()
var url = "ws://localhost:5000"
onready var handIcon = $HandArea/Sprite
onready var handArea = $HandArea
onready var boxArea = $BoxArea
var openHand = preload("res://pics/open_hand.png")
var closedHand = preload("res://pics/closed_hand.png")

var isHandOnBox = false
var handClosed = false

func _ready():
	client.connect("data_received", self, "_on_data_recieved")
	
	var err = client.connect_to_url(url)
	if err != OK:
		set_process(false)
		print("Unable to connect")
		
func _process(_delta):
	client.poll()
	
func _physics_process(delta):
	if(handClosed && isHandOnBox):
		print("TRUUUE!")
		boxArea.position = handArea.position
	pass
	
var dict = null


#Function returns true if hand is closed
func isHandClosed(handData):
	var middleFingerTop = handData[12]
	var middleFingerRoot = handData[9]
	var handRoot = handData[0]
	
	var handToFingerTop = Vector2(handRoot["x"]-middleFingerTop["x"],handRoot["y"]-middleFingerTop["y"])
	var handToFingerRoot = Vector2(handRoot["x"]-middleFingerRoot["x"],handRoot["y"]-middleFingerRoot["y"])
	#print(str(handToFingerRoot.length())  + ">" + str(handToFingerTop.length()))
	
	if(handToFingerRoot.length() > handToFingerTop.length()*1.1):
		return true
	else:
		return false

#return a vector of where the hand is relative to the screen
func getHandPositionRelative(x,y):
	return Vector2(x*get_viewport().size.x,y*get_viewport().size.y)

	
func _on_data_recieved(): 
	var payload = client.get_peer(1).get_packet().get_string_from_utf8()
	var dict = JSON.parse(payload)
	#Depending on the dict, the TYPE: varable will be FACE_DETECT, FACE_TRACK, POSE, HANDS and then the data will be in "DATA" key
	#e.g. dict.DATA == "FACE_TRACK"
	$TextEdit2.text = str(dict.result["DATA"]["landmark"][1])
	
	#Change position of sprite icon
	var handposition = getHandPositionRelative(dict.result["DATA"]["landmark"][9]["x"],dict.result["DATA"]["landmark"][9]["y"])
	handArea.position = handposition
	
	#Change color of hand if its closed
	if(isHandClosed(dict.result["DATA"]["landmark"])):
		handIcon.texture = closedHand;
		handClosed = true;
		
	else:
		handIcon.texture = openHand;
		handClosed = false;
	
	
	
func send(data): 
	client.get_peer(1).put_packet(JSON.print(data).to_utf8())


func _on_Button_pressed():
	send($TextEdit.text)
	




func _on_HandArea_area_entered(area):
	isHandOnBox=true;
	


func _on_HandArea_area_exited(area):
	isHandOnBox=false;
	
