extends Control

var client = WebSocketClient.new()
var url = "ws://localhost:5000"
onready var handIcon = $HandArea/Sprite
onready var handArea = $HandArea
onready var boxArea = $BoxArea
var openHand = preload("res://pics/open_hand.png")
var closedHand = preload("res://pics/closed_hand.png")

var lastUpdateHand = 0


#Load in with standard values
var openHandAverage = [false,false,false,false,false]
var positionHandAverage = [Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0)]

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
	#Sets how long to wait before the track counts as gone
	var c = 100
	if(lastUpdateHand + c < OS.get_ticks_msec()):
		handIcon.modulate = Color(0.5,0.5,0.5,0.5)
	
		
	
func _physics_process(delta):
	if(handClosed && isHandOnBox):
		
		boxArea.position = handArea.position
	pass
	
var dict = null


#Pushes new data to the average array
func updateAverage(handData):
	var newestHandPosition = getHandPositionRelative(handData[9]["x"],handData[9]["y"])
	var newestIsHandClosed = isHandClosed(handData)
	
	openHandAverage.pop_back();
	positionHandAverage.pop_back();
	
	positionHandAverage.push_front(newestHandPosition)
	openHandAverage.push_front(newestIsHandClosed)
	
func getAveragePosition():
	var averageVector = Vector2(0,0)
	
	for n in positionHandAverage:
		averageVector += n
	
	return averageVector/positionHandAverage.size()
	
func getOpenHandAverage():
	var nrOfOpenHands = 0
	
	for n in openHandAverage:
		if(n):
			nrOfOpenHands +=1
	if(nrOfOpenHands > 2):
		return true
	else: 
		return false
	
		


#Function returns true if hand is closed
func isHandClosed(handData):
	var middleFingerTop = handData[12]
	var middleFingerRoot = handData[9]
	var handRoot = handData[0]
	
	var handToFingerTop = Vector2(handRoot["x"]-middleFingerTop["x"],handRoot["y"]-middleFingerTop["y"])
	var handToFingerRoot = Vector2(handRoot["x"]-middleFingerRoot["x"],handRoot["y"]-middleFingerRoot["y"])
	#print(str(handToFingerRoot.length())  + ">" + str(handToFingerTop.length()))
	if(handClosed):
		#If hand was originaly closed
		if(handToFingerRoot.length()*1.5 < handToFingerTop.length()):
			return false
		else:
			return true
	else:	
		#If hand was originaly open
		if(handToFingerRoot.length() > handToFingerTop.length()*1.1):
			return true
		else:
			return false

#return a vector of where the hand is relative to the screen
func getHandPositionRelative(x,y):
	return Vector2(x*get_viewport().size.x,y*get_viewport().size.y)

#returns true if the whole hand points against the camera
func isHandInBadPosition(handData):
	var middleFingerRoot = handData[9];
	var handRoot = handData[0]
	var thumbRoot = handData[2]
	
	var handToMiddleFingerRoot = Vector2(middleFingerRoot["x"]- handRoot["x"],middleFingerRoot["y"]-handRoot["y"])
	var handToThumbRoot = Vector2(thumbRoot["x"]- handRoot["x"],thumbRoot["y"]-handRoot["y"])
	
	print(handToMiddleFingerRoot.length()/handToThumbRoot.length())
	if(handToMiddleFingerRoot.length()<handToThumbRoot.length()):
		return true
	else:
		return false
	
func _on_data_recieved(): 
	lastUpdateHand = OS.get_ticks_msec();
	
	var payload = client.get_peer(1).get_packet().get_string_from_utf8()
	var dict = JSON.parse(payload)
	#Depending on the dict, the TYPE: varable will be FACE_DETECT, FACE_TRACK, POSE, HANDS and then the data will be in "DATA" key
	#e.g. dict.DATA == "FACE_TRACK"
	$TextEdit2.text = str(dict.result["DATA"]["landmark"][1])
	
	updateAverage(dict.result["DATA"]["landmark"])
	
	
	#Change position of sprite icon
	
	handArea.position = getAveragePosition()
	
	if(isHandInBadPosition(dict.result["DATA"]["landmark"])):
		handIcon.modulate = Color(1,0,0,0.5)
	else:
		handIcon.modulate = Color(1,1,1,1)
		#Change color of hand if its closed
		if(getOpenHandAverage()):
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
	
