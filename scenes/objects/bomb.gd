extends RigidBody2D

@onready var timer = $ExplosionTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = 2
	timer.start()
	timer.timeout.connect(_on_explosion_timer_timeout)

func _on_explosion_timer_timeout():
	explode()

func explode():
	var bodies = $ExplosionRadius.get_overlapping_bodies()
	for body in bodies:
		if body is RigidBody2D:
			print("Body ", body)
			var direction = (body.global_position - global_position).normalized()
			var force = direction * 500
			body.apply_impulse(force, Vector2())
		elif body is CharacterBody2D:
			print("CharacterBody ", body)
			var direction = (body.global_position - global_position).normalized()
			var force = direction * 500
			body.velocity += force  # Directly modify the velocity
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
