extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var sign_scene = preload("res://scenes/interactable_sign.tscn")
var fisherman_scene = preload("res://scenes/fisherman_npc.tscn")

func _ready() -> void:
	# Start overworld BGM
	BackgroundMusic.play_for_scene("res://scenes/firstmap.tscn")

	# Spawn player
	var player = player_scene.instantiate()
	if GameState.use_custom_spawn:
		player.position = GameState.target_spawn_pos
		GameState.use_custom_spawn = false
	else:
		player.position = Vector2(500, 300)
	add_child(player)
	
	# Spawn bonfire/sign
	var sign_obj = sign_scene.instantiate()
	sign_obj.position = Vector2(450, 300)
	add_child(sign_obj)

	# Spawn Fisherman NPC near the water
	var fisherman = fisherman_scene.instantiate()
	fisherman.position = Vector2(620, 260)
	add_child(fisherman)

	# Fish in the pond are placed manually in the Godot scene editor.
	# Open firstmap.tscn, drag in FishSwimmer scenes and position them on the pond.
	# Configure each fish individually via the Inspector (swim axis, speed, offset, tint).
