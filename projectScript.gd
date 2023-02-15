extends Node

var faceClosedIcon = preload("res://pics/faceClosed.png")
var faceOpenIcon = preload("res://pics/faceOpen.png")
onready var pointerArea = $PointerArea
onready var boxArea = $BoxArea

onready var pointerSprite = $PointerArea/Sprite
var client = WebSocketClient.new()
var url = "ws://localhost:5000"

var tiltHead = "Neutral"
var tiltPositions = ["Right", "Neutral", "Left"]
var tiltHeadRaw = 0

var pitchHead = "Neutral"
var pitchPositions = ["Up", "Neutral", "Down"]
var pitchHeadLeftEar = 0
var pitchHeadRightEar = 0

var mouthOpen = "Closed"
var mouthPositions = ["Closed", "Open"]
var mouthOpenRaw = 0

var haveGrabbed = false

var offset = Vector2(0,0)


var isPointerOnBox = false

var faceLandMarks = {}

# -1 = right, 0 = neutral, 1 left
func discreetTilt(rawTilt):
	if (rawTilt < -10):
		return -1
	elif (rawTilt > 10):
		return 1
	else:
		return 0
		
# -1 = up, 0 = neutral, 1 down
func discreetPitch(rawPitch):
	
	if (rawPitch > -10):
		return -1
	elif (rawPitch < -40):
		return 1
	else:
		return 0
	"""
	if (rawPitch > 0):
		return -1
	elif (rawPitch > -70):
		return 1
	else:
		return 0
	"""
		
# 0 = closed, 1 = open
func discreetMouth(rawMouth):
	if (rawMouth < 40):
		return 0
	else:
		return 1

func createLandmarks(faceData):
	var allLandmarks = faceData.result["DATA"]["landmark"]
	faceLandMarks["topHead"] = extractVector2(allLandmarks[10])
	faceLandMarks["bottomHead"] = extractVector2(allLandmarks[152])
	faceLandMarks["topLip"] = extractVector2(allLandmarks[13])
	faceLandMarks["bottumLip"] = extractVector2(allLandmarks[14])
	faceLandMarks["leftMouth"] = extractVector2(allLandmarks[78])
	faceLandMarks["rightMouth"] = extractVector2(allLandmarks[308])
	faceLandMarks["rightEar"] = extractVector2(allLandmarks[454])
	faceLandMarks["leftEar"] = extractVector2(allLandmarks[234])
	faceLandMarks["noseTip"] = extractVector2(allLandmarks[94])
	
func extractVector2(landmark):
	return Vector2(landmark["x"], landmark["y"])

func isMouthOpen(faceLandMarks):
	var vectorLeftMothToLip = faceLandMarks["bottumLip"]-faceLandMarks["topLip"]
	#print(str(vectorLeftMothToLip.length()))
	var topLip = faceLandMarks["topLip"]-faceLandMarks["leftMouth"]
	var buttomLip = faceLandMarks["bottumLip"]-faceLandMarks["leftMouth"]
	mouthOpenRaw = rad2deg(topLip.angle_to(buttomLip))
	
func headPitch(faceLandMarks):
	"""
	var vectorEarToEar = faceLandMarks["leftEar"]-faceLandMarks["rightEar"]
	var vectorEarToNose = faceLandMarks["leftEar"]-faceLandMarks["noseTip"]
	pitchHeadRaw = rad2deg(vectorEarToEar.angle_to(vectorEarToNose))
	"""
	var vectorNoseLeftEar = faceLandMarks["leftEar"] - faceLandMarks["noseTip"]
	var vectorNoseRightEar = faceLandMarks["rightEar"] - faceLandMarks["noseTip"]
	var vectorBetweenEars = faceLandMarks["leftEar"] - faceLandMarks["rightEar"]
	
	pitchHeadLeftEar = rad2deg(vectorNoseLeftEar.angle_to(vectorBetweenEars))
	pitchHeadRightEar = -rad2deg(vectorNoseRightEar.angle_to(-vectorBetweenEars))
	
func headTilt(faceLandMarks):
	var vectorTopToButtomHead = faceLandMarks["topHead"]-faceLandMarks["bottomHead"]
	tiltHeadRaw = rad2deg(vectorTopToButtomHead.angle_to(Vector2.UP))

func _ready():
	client.connect("data_received", self, "_on_data_recieved")
	
	var err = client.connect_to_url(url)
	if err != OK:
		set_process(false)
		print("Unable to connect")
		
func _process(_delta):
	
	if(mouthOpen=="Closed" && isPointerOnBox):
		if(haveGrabbed==false):
			offset = Vector2(boxArea.position-pointerArea.position)	
			haveGrabbed = true
		
		boxArea.position = pointerArea.position+offset
	else:
		haveGrabbed=false
	client.poll()

func _physics_process(delta):
	#See which way the head is pointed
	if(tiltHead == "Right"):
		print("Riight")
		pointerArea.position.x += 1
		
	elif(tiltHead == "Left"):
		print("LEEFT")
		pointerArea.position.x -= 1
	
	if(pitchHead == "Up"):
		print("Up!")
		pointerArea.position.y -= 1
	elif(pitchHead == "Down"):
		pointerArea.position.y += 1
		print("Down!")
	
var dict = null
func _on_data_recieved(): 
	var payload = client.get_peer(1).get_packet().get_string_from_utf8()
	var dict = JSON.parse(payload)
	#Depending on the dict, the TYPE: varable will be FACE_DETECT, FACE_TRACK, POSE, HANDS and then the data will be in "DATA" key
	#e.g. dict.DATA == "FACE_TRACK"
	#Write out facePositions
	var output = "Tilt: %s (%s) \nPitch: %s (%s, %s) \nMouth: %s (%s) \n" % [tiltHead, tiltHeadRaw, pitchHead, pitchHeadLeftEar, pitchHeadRightEar,mouthOpen,mouthOpenRaw]
	$TextEdit2.text = str(output)
	#Create a dict with relevant landmarks
	createLandmarks(dict)
	
	isMouthOpen(faceLandMarks)
	headPitch(faceLandMarks)
	headTilt(faceLandMarks)
	
	
	
	tiltHead = tiltPositions[discreetTilt(tiltHeadRaw) + 1]
	mouthOpen = mouthPositions[discreetMouth(mouthOpenRaw)]
	
	if(mouthOpen=="Open"):
		pointerSprite.texture = faceOpenIcon
		
	elif(mouthOpen =="Closed"):
		pointerSprite.texture = faceClosedIcon
		
		
	
	var pitch = discreetPitch(pitchHeadLeftEar)
	if (pitch == discreetPitch(pitchHeadRightEar)):
		pitchHead = pitchPositions[pitch + 1]
	else:
		pitchHead = "CONFLICT"
	
func send(data): 
	client.get_peer(1).put_packet(JSON.print(data).to_utf8())


func _on_Button_pressed():
	send($TextEdit.text)
	





func _on_PointerArea_area_entered(area):
	
	isPointerOnBox = true
	pass # Replace with function body.


func _on_PointerArea_area_exited(area):
	
	isPointerOnBox = false
	pass # Replace with function body.
