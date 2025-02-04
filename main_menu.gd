extends ColorRect


@onready var main: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/MainMenu
@onready var levels: HBoxContainer = $CenterContainer/PanelContainer/MarginContainer/LevelsMenu

var levels_open := false


func _process(delta: float) -> void:
	if !levels_open:
		levels.hide()
		main.show()
	else:
		main.hide()
		levels.show()


func _on_start_next_button_pressed() -> void:
	pass


func _on_levels_button_pressed() -> void:
	levels_open = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	levels_open = false
