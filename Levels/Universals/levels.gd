extends Node2D


# when you enter it plays the fade in animation
func _enter_tree() -> void:
	# hides mouse
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	# fade in animation
	visible = false
	$AnimationPlayer.play("Fade in")
	$ParallaxBackground/AnimationPlayer.play("Fade in")

func _process(delta: float) -> void:
	# handles when you tell it to go back
	if Input.is_action_just_pressed("esc"):
		# plays animiation of fade out while leaving
		$AnimationPlayer.play("Fade out")
		$ParallaxBackground/AnimationPlayer.play("Fade out")
		await get_tree().create_timer(0.5).timeout
		
		# tells the main menu to return and fade in while the level leaves
		get_parent().get_child(0).level_done("left")
		queue_free()
	
	# if you fall out of bounds then it returns you
	if find_child("Player").position.y > 1000 or Input.is_action_just_pressed("restart"):
		# fades out
		$AnimationPlayer.play("Fade out")
		$ParallaxBackground/AnimationPlayer.play("Fade out")
		await get_tree().create_timer(0.5).timeout
		
		# returns the player to (0, 0) AKA spawn
		find_child("Player").position = Vector2(0, 0)
		
		# fades back in
		$AnimationPlayer.play("Fade in")
		$ParallaxBackground/AnimationPlayer.play("Fade in")

# when you reach the end of the level it updates the main menu and returns you
func unlocked():
	$AnimationPlayer.play("Fade out")
	$ParallaxBackground/AnimationPlayer.play("Fade out")
	await get_tree().create_timer(0.5).timeout
	if self.name == "Tutorial":
		get_parent().get_child(0).level_done("tutorial")
	else:
		get_parent().get_child(0).level_done("complete")
	
	queue_free()
