extends Node2D


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		$Right.modulate = Color(0, 255, 0)
	
	if Input.is_action_just_pressed("ui_left"):
		$Left.modulate = Color(0, 255, 0)
	
	if Input.is_action_just_pressed("jump"):
		$Jump.modulate = Color(0, 255, 0)
	
	if Input.is_action_just_pressed("restart"):
		$Reset.modulate = Color(0, 255, 0)
	
	if Input.is_action_just_pressed("esc"):
		$Quit.modulate = Color(0, 255, 0)
