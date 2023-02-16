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
	match (gameState):
		State.AIMING:
			if (interpreter.mouthOpen):
				angle = Vector2.UP.rotated(deg2rad(maxAngle * -interpreter.tiltHeadNormalised))
				print(angle)
				gameState = State.SHOOTING
		State.SHOOTING:
			if (interpreter.pitchHead == "Up"):
				$BallBody.shoot(angle, shootingForce * interpreter.mouthOpenNormalised)
				gameState = State.PLAYING
		State.PLAYING:
			print("Playing")
	

func _on_data_recieved(): 
	var payload = client.get_peer(1).get_packet().get_string_from_utf8()
	var dict = JSON.parse(payload)
	
	interpreter.interpretData(dict)
	
