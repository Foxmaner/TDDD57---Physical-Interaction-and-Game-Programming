extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var interpreter = get_node("../BodyInterpreter")


# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	pass # Replace with function body.



func _draw():
	var radius = 1
	if(interpreter.rawFace.empty()==false):
		print(interpreter.rawFace.size())
		for i in interpreter.rawFace:
			draw_circle((i-interpreter.rawFace[0])*300, radius, Color.green)
	
	
	
	
