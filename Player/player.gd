extends CharacterBody2D


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


const SPEED := 300.0
const JUMP_VELOCITY := -550.0


func _ready() -> void:
	$Camera2D.make_current()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		anim.play("Jump")

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		
		if direction > 0:
			anim.flip_h = false
		elif direction < 0:
			anim.flip_h = true
		
		if is_on_floor():
			anim.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			anim.play("Idle")
	
	if $ShapeCast2D.is_colliding():
		var interacted = $ShapeCast2D.get_collider(0)
		interacted.get_parent().unlocked()
	
	move_and_slide()
