extends ColorRect


var save_path = "user://variable.save"


# creating the variables to each screen
@onready var main: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/MainMenu
@onready var levels: HBoxContainer = $CenterContainer/PanelContainer/MarginContainer/LevelsMenu

# where the buttons for eaach level are stored
@onready var level_scroll_container: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/LevelsMenu/LevelsVBox/VScrollBar/LevelScrollContainer

# level menu opened and levels unlocked
var levels_open := false
var level_done_menu := false
@export var levels_unlock := 1

# level number, path to level
var all_levels = {
	"path1": preload("res://Levels/level_1.tscn"),
	"path2": preload("res://Levels/level_2.tscn")
}


func _ready() -> void:
	# makes the physics really smooth
	Engine.physics_ticks_per_second = int(DisplayServer.screen_get_refresh_rate())
	
	# loads the players saved levels_unlock
	load_data()
	
	# updates the start_next button
	start_next()
	
	# fades in the screen
	$AnimationPlayer.play("Fade in")


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


# plays the most recently unlocked level, if the unlocked level is after the last level then it just plays last level
func _on_start_next_button_pressed() -> void:
	if levels_unlock > all_levels.size():
		level_buttons(all_levels["path" + str(all_levels.size())])
	else:
		level_buttons(all_levels["path" + str(levels_unlock)])


# opens the level select page
func _on_levels_button_pressed() -> void:
	levels_open = true
	gen_levels()


# leaves the game / full close
func _on_quit_button_pressed() -> void:
	# saves the levels_unlock for later use
	save()
	
	# sends you back to the website before
	JavaScriptBridge.eval("window.location.href='https://stunning-telegram-7x547wvpgvv3wrj4-8080.app.github.dev/uses.html'")
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
	$CenterContainer/PanelContainer/MarginContainer/MainMenu/Start_NextButton.disabled = true
	$AnimationPlayer.play("Fade out")
	await get_tree().create_timer(0.5).timeout
	var instance = path.instantiate()
	get_parent().add_child(instance)
	$CenterContainer/PanelContainer/MarginContainer/MainMenu/Start_NextButton.disabled = false


# makes the start_next button display proper text for your progress
func start_next():
	if levels_unlock == 1:
		# very first level
		find_child("Start_NextButton").text = "Start"
		find_child("Start_NextButton").disabled = false
	elif  levels_unlock > all_levels.size(): 
		# final level
		find_child("Start_NextButton").text = "Completed"
		find_child("Start_NextButton").disabled = true
	else: 
		# anywhere in between
		find_child("Start_NextButton").text = "Next"
		find_child("Start_NextButton").disabled = false


# when the level is completed it handles returning to main menu
func level_done(why):
	$AnimationPlayer.play("Fade in")
	
	# if the reason for leaving is the level is complete then it updates the levels unlocked
	if why == "complete":
		levels_unlock = int(str(get_parent().get_child(1).name).trim_prefix("Level")) + 1
		start_next()
	
	gen_levels()


func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(levels_unlock)


func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		levels_unlock = file.get_var(levels_unlock)
	else:
		print("No Data Saved...")
		levels_unlock = 1
