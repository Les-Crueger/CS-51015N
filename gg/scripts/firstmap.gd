extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var sign_scene = preload("res://scenes/interactable_sign.tscn")
var fisherman_scene = preload("res://scenes/fisherman_npc.tscn")
var fish_swimmer_scene = preload("res://scenes/fish_swimmer.tscn")

func _ready() -> void:
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
	sign_obj.position = Vector2(700, 300)
	add_child(sign_obj)

	# Spawn Fisherman NPC near the water
	var fisherman = fisherman_scene.instantiate()
	fisherman.position = Vector2(620, 260)
	add_child(fisherman)

	# Spawn swimming fish in the water
	var fish1 = fish_swimmer_scene.instantiate()
	fish1.position = Vector2(850, 320)
	add_child(fish1)

	var fish2 = fish_swimmer_scene.instantiate()
	fish2.position = Vector2(900, 400)
	add_child(fish2)
