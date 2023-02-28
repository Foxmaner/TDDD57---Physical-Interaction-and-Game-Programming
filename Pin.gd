extends StaticBody2D

export var points = 10

export var score = 0

func _ready():
	pass # Replace with function body.

#func _process(delta):
#	pass

func _draw():
	var radius = get_node("CollisionShape2D").shape.radius
	draw_circle(Vector2(0,0), radius, Color.blue)


func _on_Hitbox_body_entered(body):
	var groups = body.get_groups()
	if (groups.has("balls")):
		score += points
