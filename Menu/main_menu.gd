extends ColorRect


@onready var main: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/MainMenu
@onready var levels: HBoxContainer = $CenterContainer/PanelContainer/MarginContainer/LevelsMenu

@onready var level_scroll_container: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/LevelsMenu/LevelsVBox/VScrollBar/LevelScrollContainer

var levels_open := false

# level number, path to level
var all_levels = {
	1: preload("res://Levels/level_1.tscn"),
	2: preload("res://Levels/level_2.tscn")
}


func _process(delta: float) -> void:
	if !levels_open:
		levels.hide()
		main.show()
	else:
		main.hide()
		levels.show()
	
	if get_parent().get_child_count() > 1:
		hide()
	else:
		show()


func _on_start_next_button_pressed() -> void:
	pass


func _on_levels_button_pressed() -> void:
	levels_open = true
	gen_levels()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	levels_open = false


func gen_levels():
	for child in level_scroll_container.get_child_count():
		level_scroll_container.get_child(child).queue_free()
	
	for lvls in all_levels:
		var new_button = Button.new()
		level_scroll_container.add_child(new_button)
		new_button.size_flags_horizontal = Control.SIZE_FILL
		new_button.text = str(lvls)
		new_button.connect("pressed", level_buttons.bind(all_levels[lvls]))


func level_buttons(path):
	var instance = path.instantiate()
	get_parent().add_child(instance)
