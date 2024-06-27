extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Make direction available to all functions
var direction = 0

# Bombs
var Bomb = preload("res://scenes/objects/bomb.tscn")

@onready var animations = $Pirate

var idle_timer_started = false
var double_jumped = false

func _ready():
	$RandomIdleTimer.wait_time = 2
	$RandomIdleTimer.timeout.connect(_on_random_idle_timer_timeout)

func _on_random_idle_timer_timeout():
	animations.play("idle")
	$RandomIdleTimer.wait_time = randf_range(2, 10)
	$RandomIdleTimer.start()

func handleMovement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("ui_up") and not is_on_floor() and not double_jumped:
		double_jumped = true
		velocity.y = JUMP_VELOCITY
	
	if is_on_floor() and double_jumped:
		double_jumped = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func updateAnimation():
	if velocity.length() != 0:
		idle_timer_started = false
		if velocity.x < 0: 
			direction = "LEFT"
			$Pirate.flip_h = true
		elif velocity.x > 0: 
			direction = "RIGHT"
			$Pirate.flip_h = false
		animations.play("run")
	else:
		if not idle_timer_started:
			animations.play("idle")
			animations.set_frame_and_progress(0,0)
			idle_timer_started = true
			$RandomIdleTimer.start()

func handleAttack():
	if Input.is_action_just_pressed("player_dropBomb"):
		drop()

func drop():
	var b = Bomb.instantiate()
	b.position = global_position
	get_tree().root.add_child(b)

func _physics_process(delta):
	handleMovement(delta)
	handleAttack()
	updateAnimation()
	move_and_slide()
