extends ColorRect


# creating the variables to each screen
@onready var main: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/MainMenu
@onready var levels: HBoxContainer = $CenterContainer/PanelContainer/MarginContainer/LevelsMenu

# where the buttons for eaach level are stored
@onready var level_scroll_container: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/LevelsMenu/LevelsVBox/VScrollBar/LevelScrollContainer

# level menu opened and levels unlocked
var levels_open := false
@export var levels_unlock := 1

# level number, path to level
var all_levels = {
	"path1": preload("res://Levels/level_1.tscn"),
	"path2": preload("res://Levels/level_2.tscn")
}


func _ready() -> void:
	start_next()


func _process(delta: float) -> void:
	# handles each page opening and closing
	if !levels_open:
		levels.hide()
		main.show()
	else:
		main.hide()
		levels.show()
	
	# checks if you are in a level and hides if so
	if get_parent().get_child_count() > 1:
		hide()
	else:
		show()


# plays the most recently unlocked level
func _on_start_next_button_pressed() -> void:
	level_buttons(all_levels["path" + str(levels_unlock)])


# opens the level select page
func _on_levels_button_pressed() -> void:
	levels_open = true
	gen_levels()


# leaves the game / full close
func _on_quit_button_pressed() -> void:
	get_tree().quit()


# closes the level select page
func _on_back_button_pressed() -> void:
	levels_open = false
	
	start_next()


func gen_levels():
	# removes all test button children
	for child in level_scroll_container.get_child_count():
		level_scroll_container.get_child(child).queue_free()
	
	# for each item listed in the dict
	for lvls in all_levels:
		# makes the button and gets the number
		var new_button = Button.new()
		var level_num = lvls.trim_prefix("path")
		
		# makes it a child of the scroll container
		level_scroll_container.add_child(new_button)
		
		# sets the proper settings, horizontal fill, text, and font/size
		new_button.size_flags_horizontal = Control.SIZE_FILL
		new_button.text = level_num
		new_button.theme = preload("res://Menu/main_font.tres")
		
		# checks to see if you have beaten it and changes color and availibility as so
		if int(level_num) < levels_unlock:
			new_button.modulate = Color(0, 255, 0)
		elif int(level_num) == levels_unlock:
			new_button.modulate = Color(255, 255, 0)
		else:
			new_button.modulate = Color(255, 0, 0)
			new_button.disabled = true
		
		# connects each button to the pressed function to bring you to the proper level
		new_button.connect("pressed", level_buttons.bind(all_levels[lvls]))


# sends you to the level of your choosing on press
func level_buttons(path):
	var instance = path.instantiate()
	get_parent().add_child(instance)


# makes the start_next button display proper text for your progress
func start_next():
	if levels_unlock == 1:
		find_child("Start_NextButton").text = "Start"
	else:
		find_child("Start_NextButton").text = "Next"


func level_done():
	levels_unlock = int(str(get_parent().get_child(1).name).trim_prefix("Level")) + 1
	gen_levels()
	
