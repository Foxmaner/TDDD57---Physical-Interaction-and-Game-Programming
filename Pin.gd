extends StaticBody2D

export var points = 10
export var score = 0

onready var timer = $Timer

var currentColor = Color.blue

func _ready():
	timer.one_shot = false


func _draw():
	var radius = get_node("CollisionShape2D").shape.radius
	draw_circle(Vector2(0,0), radius, currentColor)


func _on_Hitbox_body_entered(body):
	var groups = body.get_groups()
	if (groups.has("balls")):
		score += points
		currentColor = Color.green
		update()
		timer.start(.5)
		yield(timer, "timeout")
		currentColor = Color.blue
		update()
