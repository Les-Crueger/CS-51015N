extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var sign_scene = preload("res://scenes/interactable_sign.tscn")

func _ready() -> void:
	# Spawn player
	var player = player_scene.instantiate()
	player.position = Vector2(42,448)
	add_child(player)
	
	# Spawn sign
	var sign_obj = sign_scene.instantiate()
	sign_obj.position = Vector2(700, 300)
	add_child(sign_obj)
