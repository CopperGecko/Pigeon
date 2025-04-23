extends ColorRect


var save_path = "user://levels_unlocked.save"


# creating the variables to each screen
@onready var main: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/MainMenu
@onready var levels: HBoxContainer = $CenterContainer/PanelContainer/MarginContainer/LevelsMenu

# where the buttons for eaach level are stored
@onready var level_scroll_container: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/LevelsMenu/LevelsVBox/VScrollBar/LevelScrollContainer

# level menu opened and levels unlocked
var levels_open := false
var level_done_menu := false
@export var levels_unlock := 0

# reset all levels progress
var confirm_reset = false


# all levels as a dictionary
# level number, level path
var all_levels = {
	"level0" : ["tutoral", preload("res://Levels/tutorial.tscn")],
	"level1" : [1, preload("res://Levels/level_1.tscn")],
	"level2" : [2, preload("res://Levels/level_2.tscn")],
	"level3" : [3, preload("res://Levels/level_3.tscn")]
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
	
	if confirm_reset == false:
		$CenterContainer/PanelContainer/MarginContainer/LevelsMenu/LevelsVBox/ResetAll/Confirm.hide()
	elif confirm_reset == true:
		$CenterContainer/PanelContainer/MarginContainer/LevelsMenu/LevelsVBox/ResetAll/Confirm.show()


# plays the most recently unlocked level, if the unlocked level is after the last level then it just plays last level
func _on_start_next_button_pressed() -> void:
	level_buttons(all_levels.keys()[levels_unlock])


# opens the level select page
func _on_levels_button_pressed() -> void:
	levels_open = true
	gen_levels()


# leaves the game / full close
func _on_quit_button_pressed() -> void:
	# saves the levels_unlock for later use
	save_data()
	
	# sends you back to the website before
	JavaScriptBridge.eval("window.location.href='https://stunning-telegram-7x547wvpgvv3wrj4-8080.app.github.dev/uses.html'")
	get_tree().quit()


# closes the level select page
func _on_back_button_pressed() -> void:
	levels_open = false
	
	start_next()


func gen_levels():
	save_data()
	
	# removes all test button children
	for child in level_scroll_container.get_child_count():
		level_scroll_container.get_child(child).queue_free()
	
	# for each item listed in the dict
	for lvls in all_levels:
		# makes the button and gets the number
		var new_button = Button.new()
		var level_num = all_levels[lvls][0]
		
		# makes it a child of the scroll container
		level_scroll_container.add_child(new_button)
		
		# sets the proper settings, horizontal fill, text, and font/size
		new_button.size_flags_horizontal = Control.SIZE_FILL
		new_button.text = str(level_num)
		new_button.theme = preload("res://Menu/main_font.tres")
		
		# checks to see if you have beaten it 
		# and changes color and availibility as so
		if int(level_num) < levels_unlock:
			new_button.modulate = Color(0, 255, 0)
		elif int(level_num) == levels_unlock:
			new_button.modulate = Color(255, 255, 0)
		else:
			new_button.modulate = Color(255, 0, 0)
			new_button.disabled = true
		
		# connects each button to the 
		# pressed function to bring you to the proper level
		new_button.connect("pressed", level_buttons.bind(lvls))


# sends you to the level of your choosing on press
func level_buttons(path):
	# disables all level buttons so you can have the level open more than once
	if level_scroll_container.get_child_count() > 0:
		for child in level_scroll_container.get_child_count():
			level_scroll_container.get_child(child).disabled = true
	
	$CenterContainer/PanelContainer/MarginContainer/MainMenu/Start_NextButton.disabled = true
	
	# level in procedure
	$AnimationPlayer.play("Fade out")
	await get_tree().create_timer(0.5).timeout
	
	var instance = all_levels[path][1].instantiate()
	get_parent().add_child(instance)
	
	# turns the start button back on
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
	elif levels_unlock == 0:
		# tutorial level
		find_child("Start_NextButton").text = "Tutorial"
		find_child("Start_NextButton").disabled = false
	else: 
		# anywhere in between
		find_child("Start_NextButton").text = "Next"
		find_child("Start_NextButton").disabled = false


# when the level is completed it handles returning to main menu
func level_done(why):
	# when level done reveals mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# fades in main menu
	$AnimationPlayer.play("Fade in")
	
	# if the reason for leaving is the level is complete then it updates the levels unlocked
	if why == "complete":
		# updates the levels_unlocked to be the latest one
		var done_level = int(str(get_parent().get_child(1).name).trim_prefix("Level")) + 1
		if levels_unlock < done_level:
			levels_unlock = done_level
		
		# saves all data to be used later
		start_next()
		save_data()
	
	# checks if the tutorial was done and its all you've done
	elif why == "tutorial":
		if levels_unlock <= 0:
			levels_unlock = 1
			
			start_next()
			save_data()
	
	# updates the levels screen to match levels unlocked
	gen_levels()


func save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(levels_unlock)


func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		levels_unlock = file.get_var(levels_unlock)
	else:
		print("No Data Saved...")
		levels_unlock = 0



func _on_reset_all_pressed() -> void:
	if confirm_reset == false:
		confirm_reset = true
	elif confirm_reset == true:
		confirm_reset = false


func _on_yes_pressed() -> void:
	if levels_unlock > 0:
		levels_unlock = 1
		gen_levels()
	confirm_reset = false


func _on_no_pressed() -> void:
	confirm_reset = false
