extends CharacterBody2D


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


const SPEED := 300.0
const JUMP_VELOCITY := -550.0

func _ready() -> void:
	# sets up the camera becasue of how the level system works
	$Camera2D.make_current()


func _physics_process(delta: float) -> void:
	# adds the gravity and jump animation while in the air
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		# swaps the sprite whether you are falling or going up
		if velocity.y < 0:
			anim.play("Jump_up")
		elif velocity.y > 0:
			anim.play("Fall_down")
	
	# handle jumping
	if Input.is_action_just_pressed("jump") and (is_on_floor() or !$CoyoteTimer.is_stopped()):
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		
		# flips the player when they face other ways
		if direction > 0:
			anim.flip_h = false
		elif direction < 0:
			anim.flip_h = true
		
		# plays the run animation if you are moving on the ground
		if is_on_floor():
			anim.play("Run")
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * 15)
		
		# makes the slow to 0 become 0 after a bit instead of really small, for ease of use
		if velocity.x > -0.01 and velocity.x < 0.01:
			velocity.x = 0
		
		# plays the idle animation if you arent doing anything
		if is_on_floor():
			anim.play("Idle")
	
	# checker for hitting an interactable
	if $ShapeCast2D.is_colliding():
		var interacted = $ShapeCast2D.get_collider(0)
		interacted.get_parent().unlocked()
	
	# gets if the player is on the floor before move_and_slide
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	# after move and slide it compares the frame before AKA was_on_floor and starts coyote timer
	if was_on_floor and !is_on_floor():
		$CoyoteTimer.start()
