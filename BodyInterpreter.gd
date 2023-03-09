extends Node

var tiltHead = "Neutral"
var tiltPositions = ["Right", "Neutral", "Left"]
var tiltHeadRaw = 0
var tiltHeadNormalised = 0

var pitchHead = "Neutral"
var pitchPositions = ["Up", "Neutral", "Down"]
var pitchHeadLeftEar = 0
var pitchHeadRightEar = 0

var mouthOpen = false
var mouthOpenRaw = 0
var mouthOpenNormalised = 0
var mouthOpenNormalisedBuffer = []
var mouthOpenNormalisedSmoothed = 0

var faceLandMarks = {}

var rawFace = []

# -1 = right, 0 = neutral, 1 left
func discreetTilt(rawTilt):
	if (rawTilt < -10):
		return -1
	elif (rawTilt > 10):
		return 1
	else:
		return 0
		
func normaliseTilt(rawTilt):
	return clamp(rawTilt / 30, -1, 1)
		
# -1 = up, 0 = neutral, 1 down
func discreetPitch(rawPitch):
	
	if (rawPitch > -10):
		return -1
	elif (rawPitch < -40):
		return 1
	else:
		return 0
		
func discreetMouth(rawMouth):
	if (rawMouth < 40):
		return false
	else:
		return true
		
func normaliseMouth(rawMouth):
	if(mouthOpenNormalisedBuffer.size()<10):
		mouthOpenNormalisedBuffer.push_back(clamp(rawMouth/100, 0, 1))
	else:
		mouthOpenNormalisedBuffer.pop_front()
		mouthOpenNormalisedBuffer.push_back(clamp(rawMouth/100, 0, 1))
	var total = 0
	for i in mouthOpenNormalisedBuffer:
		total = total + i
	mouthOpenNormalisedSmoothed = total/mouthOpenNormalisedBuffer.size()	
	
	return clamp(rawMouth/100, 0, 1)

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
	
	rawFace.clear()
	for i in allLandmarks:
		rawFace.append(extractVector2(i))
	
	
func extractVector2(landmark):
	return Vector2(landmark["x"], landmark["y"])

func isMouthOpen():
	var topLip = faceLandMarks["topLip"] - faceLandMarks["leftMouth"]
	var buttomLip = faceLandMarks["bottumLip"] - faceLandMarks["leftMouth"]
	mouthOpenRaw = rad2deg(topLip.angle_to(buttomLip))
	
func headPitch():
	var vectorNoseLeftEar = faceLandMarks["leftEar"] - faceLandMarks["noseTip"]
	var vectorNoseRightEar = faceLandMarks["rightEar"] - faceLandMarks["noseTip"]
	var vectorBetweenEars = faceLandMarks["leftEar"] - faceLandMarks["rightEar"]
	
	pitchHeadLeftEar = rad2deg(vectorNoseLeftEar.angle_to(vectorBetweenEars))
	pitchHeadRightEar = -rad2deg(vectorNoseRightEar.angle_to(-vectorBetweenEars))
	
func headTilt():
	var vectorTopToButtomHead = faceLandMarks["topHead"]-faceLandMarks["bottomHead"]
	tiltHeadRaw = rad2deg(vectorTopToButtomHead.angle_to(Vector2.UP))

func toString():
	return "Tilt: %s (%s) \nPitch: %s (%s, %s) \nMouth: %s (%s) \n" % \
	 	[tiltHead, tiltHeadRaw, pitchHead, pitchHeadLeftEar, 
		 pitchHeadRightEar, mouthOpen, mouthOpenRaw]

func interpretData(dict):
	createLandmarks(dict)

	isMouthOpen()
	headPitch()
	headTilt()
	
	tiltHead = tiltPositions[discreetTilt(tiltHeadRaw) + 1]
	tiltHeadNormalised = normaliseTilt(tiltHeadRaw)
	mouthOpen = discreetMouth(mouthOpenRaw)
	mouthOpenNormalised = normaliseMouth(mouthOpenRaw)
	
	var pitch = discreetPitch(pitchHeadLeftEar)
	if (pitch == discreetPitch(pitchHeadRightEar)):
		pitchHead = pitchPositions[pitch + 1]
	else:
		pitchHead = "CONFLICT"
