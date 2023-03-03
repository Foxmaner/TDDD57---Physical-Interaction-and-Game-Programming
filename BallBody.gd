extends RigidBody2D

var reset  = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func shoot(dir, force):
	mode = RigidBody2D.MODE_RIGID
	apply_impulse(Vector2(0,0), dir*force)

func _draw():
	var radius = get_node("CollisionShape2D").shape.radius
	draw_circle(Vector2(0,0), radius, Color.red)

func _integrate_forces (state):
	if(reset):
		position=Vector2(506,463)
		state.transform = Transform2D(180,Vector2(506,463))
		state.linear_velocity = Vector2()
		mode = RigidBody2D.MODE_KINEMATIC
		reset = false
	
