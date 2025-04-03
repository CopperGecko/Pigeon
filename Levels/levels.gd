extends Node2D



func _enter_tree() -> void:
	visible = false
	$AnimationPlayer.play("Fade in")


func _process(delta: float) -> void:
	# handles when you tell it to go back
	if Input.is_action_just_pressed("esc"):
		# ungrabs mouse
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		# plays animiation of fade out while leaving
		$AnimationPlayer.play("Fade out")
		await get_tree().create_timer(0.5).timeout
		
		# tells the main menu to return and fade in while the level leaves
		get_parent().get_child(0).level_done("left")
		queue_free()


func unlocked():
	# when you reach the end of the level it updates the main menu and returns you
	$AnimationPlayer.play("Fade out")
	await get_tree().create_timer(0.5).timeout
	get_parent().get_child(0).level_done("complete")
	queue_free()
