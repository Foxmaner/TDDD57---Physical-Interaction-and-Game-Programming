extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var interpreter = get_node("../BodyInterpreter")


# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	pass # Replace with function body.

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, 5)
		

func _draw():
	
	if(interpreter.rawFace.empty()==false):
		#Draw Face
		var radius = 1
		
		var norm = interpreter.rawFace[10].distance_to(interpreter.rawFace[152])
		for i in interpreter.rawFace:
			draw_circle((((i-interpreter.rawFace[0])*200)/norm), radius, Color.green)
		
		
		#Draw tilt indicator
		var headTilt = interpreter.tiltHeadNormalised
		var center = (interpreter.rawFace[10]-interpreter.rawFace[0])*600+(Vector2(0,0))
		var arcRadius = 100
		var angle_from = 0
		var angle_to = 0
		if(headTilt>0):
			angle_from = -100*headTilt
			angle_to = 0
		else:
			angle_from = 0
			angle_to = -(100*headTilt)
		var color = Color(1.0, 1.0-abs(headTilt), 1.0-abs(headTilt))
		draw_circle_arc(center, arcRadius, angle_from, angle_to, color)
		
		#Draw mouth indicator
		var mouthOpenNormalised = interpreter.mouthOpenNormalised
		var mouthTop = (interpreter.rawFace[12]-interpreter.rawFace[0])*600
		var mouthButtom = (interpreter.rawFace[15]-interpreter.rawFace[0])*600
		var mouthBallColor = Color(1.0, 1.0-abs(mouthOpenNormalised), 1.0-abs(mouthOpenNormalised))
		draw_circle((mouthButtom+mouthTop)/2, 15*mouthOpenNormalised, mouthBallColor)
		
		
	
	
	
	
