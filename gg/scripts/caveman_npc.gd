extends StaticBody2D

@export var npc_name: String = "Caveman Ugg"

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var interact_area: Area2D = $InteractArea

var tex_caveman = preload("res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/cache/027-1-1-icon.png")

func _ready() -> void:
	if label:
		label.visible = false
	if sprite:
		sprite.texture = tex_caveman
		sprite.region_enabled = false # Static icon image — no animation needed

func interact() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return

	# Face the player
	if sprite:
		var diff = player.global_position - global_position
		if abs(diff.x) > 5.0:
			if diff.x < 0:
				sprite.scale.x = -1
			else:
				sprite.scale.x = 1

	# Jump juice
	var tween = create_tween()
	tween.tween_property(sprite, "position:y", -6.0, 0.1)
	tween.tween_property(sprite, "position:y",  0.0, 0.1)

	if "inventory" in player and player.inventory != null:
		if not GameState.caveman_items_given:
			GameState.caveman_items_given = true
			player.inventory.add_item("Pickaxe", 1)
			_show_dialogue("Ugg: 'Oog! Welcome to cave! Take Pickaxe! Mine rocks for Iron & Flint, smelt at Furnace! Find Stone — he forge stronger tools!'")
		else:
			_show_dialogue("Ugg: Mine rocks, get ores. Find Stone to forge. Ugg give key when cave safe!")

func _show_dialogue(text: String) -> void:
	if label:
		label.text = text
		label.visible = true
		label.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(label, "modulate:a", 1.0, 0.2)
		var timer = get_tree().create_timer(4.0)
		timer.timeout.connect(func():
			if label:
				var fade = create_tween()
				fade.tween_property(label, "modulate:a", 0.0, 0.3)
				fade.finished.connect(func(): if label: label.visible = false)
		)
