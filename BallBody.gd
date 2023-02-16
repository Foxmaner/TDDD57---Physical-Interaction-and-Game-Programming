extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func shoot(dir, force):
	mode = RigidBody2D.MODE_RIGID
	apply_impulse(Vector2(0,0), dir*force)
	
