extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum State {DEFAULT, AIMING, SHOOTING, PLAYING}
onready var play = $playText
onready var shoot = $shootText
onready var sight = $sightText

# Called when the node enters the scene tree for the first time.
func _ready():
	play.modulate = Color.darkred
	shoot.modulate = Color.darkred
	sight.modulate = Color.red
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func changeState(gameState):
	match (gameState):
		State.AIMING:
			play.modulate = Color.darkred
			shoot.modulate = Color.darkred
			sight.modulate = Color.red
		State.SHOOTING:
			play.modulate = Color.darkred
			shoot.modulate = Color.red
			sight.modulate = Color.darkred
		State.PLAYING:
			play.modulate = Color.red
			shoot.modulate = Color.darkred
			sight.modulate = Color.darkred
