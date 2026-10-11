extends Node2D

var player_scene = preload("res://scenes/player.tscn")

func _ready() -> void:
	# Start third_map BGM
	BackgroundMusic.play_for_scene("res://scenes/third_map.tscn")

	# Spawn player
	var player = player_scene.instantiate()
	if GameState.use_custom_spawn:
		player.position = GameState.target_spawn_pos
		GameState.use_custom_spawn = false
	else:
		# Default fallback spawn — adjust this if needed
		player.position = Vector2(200, 400)
	add_child(player)
	
	# Add player to group so transition zones can find it
	player.add_to_group("player")
