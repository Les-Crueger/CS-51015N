extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var sign_scene = preload("res://scenes/interactable_sign.tscn")
var caveman_scene = preload("res://scenes/caveman_npc.tscn")

func _ready() -> void:
	# Start cave BGM
	BackgroundMusic.play_for_scene("res://scenes/second_map.tscn")

	# Spawn player
	var player = player_scene.instantiate()
	if GameState.use_custom_spawn:
		player.position = GameState.target_spawn_pos
		GameState.use_custom_spawn = false
	else:
		player.position = Vector2(32, 432)
	add_child(player)
	
	# Spawn sign
	var sign_obj = sign_scene.instantiate()
	sign_obj.position = Vector2(700, 300)
	add_child(sign_obj)
	
	# Spawn Caveman Ugg near cave entrance
	var caveman = caveman_scene.instantiate()
	caveman.position = Vector2(120, 430)
	add_child(caveman)
	
	# Mineable rocks are placed manually in the Godot scene editor.
	# Open second_map.tscn, drag in res://scenes/interactable_rock.tscn, and position them anywhere in the cave!
