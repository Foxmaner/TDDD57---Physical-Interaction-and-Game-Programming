extends Control

var client = WebSocketClient.new()
var url = "ws://localhost:5000"

var tiltHead = "Left"
var tiltHeadRaw = 0
var pitchHead = "Up"
var pitchHeadRaw = 0
var mouthOpen = "Closed"
var mouthOpenRaw = 0

var faceLandMarks = {}


func createLandmarks(faceData):
	var allLandmarks = faceData.result["DATA"]["landmark"]
	faceLandMarks["topHead"] = Vector2(allLandmarks[10]["x"],allLandmarks[10]["y"])
	faceLandMarks["bottomHead"] = Vector2(allLandmarks[152]["x"],allLandmarks[152]["y"])
	faceLandMarks["topLip"] = Vector2(allLandmarks[13]["x"],allLandmarks[13]["y"])
	faceLandMarks["bottumLip"] = Vector2(allLandmarks[14]["x"],allLandmarks[14]["y"])
	faceLandMarks["leftMouth"] = Vector2(allLandmarks[78]["x"],allLandmarks[78]["y"])
	faceLandMarks["rightMouth"] = Vector2(allLandmarks[308]["x"],allLandmarks[308]["y"])
	faceLandMarks["rightEar"] = Vector2(allLandmarks[454]["x"],allLandmarks[454]["y"])
	faceLandMarks["leftEar"] = Vector2(allLandmarks[234]["x"],allLandmarks[234]["y"])
	faceLandMarks["noseTip"] = Vector2(allLandmarks[94]["x"],allLandmarks[94]["y"])

func isMouthOpen(faceLandMarks):
	var vectorLeftMothToLip = faceLandMarks["bottumLip"]-faceLandMarks["topLip"]
	#print(str(vectorLeftMothToLip.length()))
	var topLip = faceLandMarks["topLip"]-faceLandMarks["leftMouth"]
	var buttomLip = faceLandMarks["bottumLip"]-faceLandMarks["leftMouth"]
	mouthOpenRaw = topLip.angle_to(buttomLip)
	print(str(topLip.angle_to(buttomLip)))
	
func headPitch(faceLandMarks):
	var vectorEarToEar = faceLandMarks["leftEar"]-faceLandMarks["rightEar"]
	var vectorEarToNose = faceLandMarks["leftEar"]-faceLandMarks["noseTip"]
	pitchHeadRaw = vectorEarToEar.angle_to(vectorEarToNose)
	
func headTilt(faceLandMarks):
	var vectorTopToButtomHead = faceLandMarks["topHead"]-faceLandMarks["bottomHead"]
	tiltHeadRaw = vectorTopToButtomHead.angle_to(Vector2.UP)

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
	#Write out facePositions
	var output = "Tilt: %s (%s) \nPitch: %s (%s) \nMouth: %s (%s) \n"% [tiltHead, tiltHeadRaw, pitchHead, pitchHeadRaw,mouthOpen,mouthOpenRaw]
	$TextEdit2.text = str(output)
	#Create a dict with relevant landmarks
	createLandmarks(dict)
	
	isMouthOpen(faceLandMarks)
	headPitch(faceLandMarks)
	headTilt(faceLandMarks)
	
	
func send(data): 
	client.get_peer(1).put_packet(JSON.print(data).to_utf8())


func _on_Button_pressed():
	send($TextEdit.text)
	
