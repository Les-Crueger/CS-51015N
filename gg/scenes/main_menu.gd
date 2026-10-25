extends Control

func _ready() -> void:
	var vbox = get_node_or_null("VBoxContainer")
	var play_btn = get_node_or_null("VBoxContainer/Play")
	var quit_btn = get_node_or_null("VBoxContainer/Quit")
	
	if play_btn:
		play_btn.pressed.connect(_on_new_game)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)

	# --- WEEK 8: Platform-Specific Tweaks ---
	var is_web: bool = OS.has_feature("web")
	
	# Add platform indicator label
	var platform_label = Label.new()
	platform_label.name = "PlatformBadge"
	platform_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	platform_label.add_theme_font_size_override("font_size", 11)
	platform_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0, 0.8))
	
	if is_web:
		platform_label.text = "🌐 Web (HTML5) Build • Fullscreen: F11 / Button Below"
		# On Web, browser security prevents quit() — hide quit button
		if quit_btn:
			quit_btn.visible = false
			
		# Add a Web Fullscreen toggle button
		if vbox:
			var fs_btn = Button.new()
			fs_btn.text = "TOGGLE FULLSCREEN"
			fs_btn.pressed.connect(func():
				var mode = DisplayServer.window_get_mode()
				if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				else:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			)
			vbox.add_child(fs_btn)
	else:
		platform_label.text = "💻 Windows Desktop PC Build • Native 60 FPS"

	if vbox:
		vbox.add_child(platform_label)

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
