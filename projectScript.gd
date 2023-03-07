extends Node2D
var client = WebSocketClient.new()
var url = "ws://localhost:5000"

onready var interpreter = get_node("BodyInterpreter")
onready var faceNode = get_node("FaceNode")
onready var gameStateTexts = get_node("gameStateText")

enum State {DEFAULT, AIMING, SHOOTING, PLAYING}
var gameState = State.AIMING

const shootingForce = 300
const maxAngle = 50

var angle = Vector2.UP
var currentScore = 0
var highScore = 0

var savegame = File.new() #file
var save_path = "user://savegame.save" #place of the file
var save_data = {"highscore": 0} #variable to store data

func _ready():
	client.connect("data_received", self, "_on_data_recieved")
	
	var err = client.connect_to_url(url)
	if err != OK:
		set_process(false)
		print("Unable to connect")
	
	if not savegame.file_exists(save_path):
		create_save()
	highScore = read_highscore()
	$ScoreText.update_values(currentScore, highScore)
		
func _process(_delta):
	client.poll()

	if Input.is_key_pressed(KEY_W):
		save_highscore()

	faceNode.update()
	match (gameState):
		State.AIMING:
			$ArrowBody.visible= true
			if (interpreter.mouthOpen):
				angle = Vector2.UP.rotated(deg2rad(maxAngle * -interpreter.tiltHeadNormalised))
				gameState = State.SHOOTING
				gameStateTexts.changeState(gameState)
			"""Rotates the arrow around the ball, and points the 
			arrow in the direction of the head"""
			var distance = 40
			var angle = deg2rad(maxAngle * -interpreter.tiltHeadNormalised) - PI/2
			$ArrowBody.position = $BallBody.position + Vector2(cos(angle), sin(angle)) * distance
			var ballToArrow = $ArrowBody.position-$BallBody.position
			$ArrowBody.rotation = -interpreter.tiltHeadNormalised
			
		State.SHOOTING:
			if (interpreter.pitchHead == "Up"):
				$BallBody.shoot(angle, shootingForce * interpreter.mouthOpenNormalised)
				gameState = State.PLAYING
				gameStateTexts.changeState(gameState)
				$ArrowBody.visible = false
			$ArrowBody.scale.y = 1+interpreter.mouthOpenNormalised
				
		State.PLAYING:
			var headTilt = interpreter.tiltHeadNormalised
			if(headTilt<-0.5):
				$rightFlipper.activate_flipper()
			elif(headTilt>0.5):
				$leftFlipper.activate_flipper()
				
	var totalScore = 0
	for pin in get_tree().get_nodes_in_group("pins"):
		totalScore += pin.score
	if totalScore != currentScore:
		currentScore = totalScore
		highScore = max(currentScore, highScore)
		$ScoreText.update_values(currentScore, highScore)


func _on_data_recieved(): 
	var payload = client.get_peer(1).get_packet().get_string_from_utf8()
	var dict = JSON.parse(payload)
	
	interpreter.interpretData(dict)
	
	
func create_save():
	savegame.open(save_path, File.WRITE)
	savegame.store_var(save_data)
	savegame.close()
	
	
func save_highscore():
	save_data["highscore"] = highScore
	savegame.open(save_path, File.WRITE)
	savegame.store_var(save_data)
	savegame.close()
	

func read_highscore():
	savegame.open(save_path, File.READ)
	save_data = savegame.get_var()
	savegame.close()
	return save_data["highscore"]	


func _on_HelpButton_pressed():
	$HelpPopup.popup(Rect2(0,0,10,10))
	

func _on_DropZone_body_entered(body):
	
	var groups = body.get_groups()
	if (groups.has("balls")):
		save_highscore()
		get_tree().reload_current_scene()
	
