extends Control

func _ready() -> void:
	# Platform tweak for Web
	if OS.has_feature("web"):
		print("Running on Web Platform - adjusting settings")
		pass

	# Connect buttons
	var play_btn = get_node_or_null("VBoxContainer/Play")
	var settings_btn = get_node_or_null("VBoxContainer/Settings")
	var quit_btn = get_node_or_null("VBoxContainer/Quit")
	
	if play_btn:
		play_btn.pressed.connect(_on_new_game)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		# Continue saved game
		if GameState.load_from_disk():
			print("Loaded game from disk!")
		else:
			print("No save found, starting new game.")
		SceneTransition.change_scene_with_loading(get_tree(), "res://scenes/firstmap.tscn", Vector2.ZERO, false)

func _on_new_game() -> void:
	# Wipe old state
	GameState.saved_inventory_slots.clear()
	GameState.is_inventory_saved = false
	GameState.caveman_items_given = false
	GameState.lit_bonfires_count = 0
	GameState.avatar_created = false
	
	# Go to character creation screen
	get_tree().change_scene_to_file("res://scenes/character_creator.tscn")

func _on_quit() -> void:
	get_tree().quit()
