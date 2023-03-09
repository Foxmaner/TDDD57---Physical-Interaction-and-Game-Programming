extends Node2D


enum State {DEFAULT, AIMING, SHOOTING, PLAYING}
onready var play = $playText
onready var shoot = $shootText
onready var sight = $sightText


func _ready():
	play.modulate = Color.darkred
	shoot.modulate = Color.darkred
	sight.modulate = Color.red


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
