extends Node2D


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		queue_free()


func unlocked():
	get_parent().get_child(0).level_done()
	queue_free()
