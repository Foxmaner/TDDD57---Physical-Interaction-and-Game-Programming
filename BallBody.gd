extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func shoot(dir, force):
	mode = RigidBody2D.MODE_RIGID
	apply_impulse(Vector2(0,0), dir*force)

func _draw():
	var radius = get_node("CollisionShape2D").shape.radius
	draw_circle(Vector2(0,0), radius, Color.red)
