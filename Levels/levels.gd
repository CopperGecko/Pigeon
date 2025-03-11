extends Node2D


func _process(delta: float) -> void:
	# handles when you tell it to go back
	if Input.is_action_just_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		queue_free()


func unlocked():
	# when you reach the end of the level it updates the main menu and returns you
	get_parent().get_child(0).level_done()
	queue_free()
