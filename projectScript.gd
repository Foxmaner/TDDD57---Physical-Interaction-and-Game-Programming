extends Node2D
var client = WebSocketClient.new()
var url = "ws://localhost:5000"

onready var interpreter = get_node("BodyInterpreter")

enum State {DEFAULT, AIMING, SHOOTING, PLAYING}
var gameState = State.AIMING

const shootingForce = 300
const maxAngle = 50

var angle = Vector2.UP

func _ready():
	client.connect("data_received", self, "_on_data_recieved")
	
	var err = client.connect_to_url(url)
	if err != OK:
		set_process(false)
		print("Unable to connect")
		
func _process(_delta):
	client.poll()
	if Input.is_key_pressed(KEY_W):
		var totalScore = 0
		for pin in get_tree().get_nodes_in_group("pins"):
			totalScore += pin.score
		print(totalScore)
	match (gameState):
		State.AIMING:
			$ArrowBody.visible= true
			if (interpreter.mouthOpen):
				angle = Vector2.UP.rotated(deg2rad(maxAngle * -interpreter.tiltHeadNormalised))
				print(angle)
				gameState = State.SHOOTING
			"""Rotates the arrow around the ball, and points the 
			arrow in the direction of the head"""
			var distance = 40
			var angle = deg2rad(maxAngle * -interpreter.tiltHeadNormalised) - PI/2
			$ArrowBody.position = $BallBody.position + Vector2(cos(angle), sin(angle)) * distance
			var ballToArrow = $ArrowBody.position-$BallBody.position
			$ArrowBody.rotation = -interpreter.tiltHeadNormalised
			
			$ArrowBody.scale.y = 1+interpreter.mouthOpenNormalised
			
		
		State.SHOOTING:
			if (interpreter.pitchHead == "Up"):
				$BallBody.shoot(angle, shootingForce * interpreter.mouthOpenNormalised)
				gameState = State.PLAYING
				
				$ArrowBody.visible= false
		State.PLAYING:
			print("Playing")
	

func _on_data_recieved(): 
	var payload = client.get_peer(1).get_packet().get_string_from_utf8()
	var dict = JSON.parse(payload)
	
	interpreter.interpretData(dict)
	


	


func _on_HelpButton_pressed():
	$HelpPopup.popup(Rect2(0,0,10,10))
	
