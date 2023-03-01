extends KinematicBody2D

enum Direction {NONE, CLOCKWISE, COUNTER_CLOCKWISE}
enum State {IDLE, HITTING, RETURNING, SPINNING}

export var hitSpeed = 4.0
export var returnSpeed = 2.0
export var startRotation = 0.0
export var maxAngle = 90.0
export var isClockwise = true

onready var interpreter = get_node("../BodyInterpreter")

onready var currentSpeed = hitSpeed
var currentState = State.IDLE

func _ready():
	print("Rotation = %s" % [startRotation])
	rotation = deg2rad(startRotation)
	if (isClockwise):
		returnSpeed = -returnSpeed
	else:
		hitSpeed = -hitSpeed

func spin(newDirection):
	currentState = State.SPINNING

func _process(delta):
	var headTilt = interpreter.tiltHeadNormalised
	if(headTilt<-0.5):
		if isClockwise:
			currentState = State.HITTING
	elif(headTilt>0.5):
		if !isClockwise:
			currentState = State.HITTING
	if Input.is_key_pressed(KEY_SPACE):
		if isClockwise:
			currentState = State.HITTING
	match (currentState):
		State.IDLE:
			return
		State.HITTING:
			var isMaxed
			if (isClockwise):
				isMaxed = rad2deg(rotation) > startRotation + maxAngle
			else:
				isMaxed = rad2deg(rotation) < startRotation - maxAngle
			if (isMaxed):
				currentSpeed = returnSpeed
				currentState = State.RETURNING
			else:
				rotation += hitSpeed * delta
		State.RETURNING:
			var hasReturned
			if (isClockwise):
				hasReturned = rad2deg(rotation) < startRotation
			else:
				hasReturned = rad2deg(rotation) > startRotation
			if (hasReturned):
				currentState = State.IDLE
			else:
				rotation += returnSpeed * delta
		State.SPINNING:
			rotation += hitSpeed * delta
