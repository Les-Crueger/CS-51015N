extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Platform tweak for Web
	if OS.has_feature("web"):
		print("Running on Web Platform - adjusting settings")
		# We could scale UI here, but for now we just log it as the "Web tweak"
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# New Game (wipe old state)
		GameState.saved_inventory_slots.clear()
		GameState.is_inventory_saved = false
		GameState.caveman_items_given = false
		GameState.lit_bonfires_count = 0
		SceneTransition.change_scene_with_loading(get_tree(), "res://scenes/firstmap.tscn", Vector2.ZERO, false)
			
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		# Continue
		if GameState.load_from_disk():
			print("Loaded game from disk!")
		else:
			print("No save found, starting new game.")
		
		# For simplicity, load first map on continue (or you could save the scene path)
		SceneTransition.change_scene_with_loading(get_tree(), "res://scenes/firstmap.tscn", Vector2.ZERO, false)
