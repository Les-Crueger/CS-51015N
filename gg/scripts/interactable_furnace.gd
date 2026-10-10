extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var interact_area: Area2D = $InteractArea

func _ready() -> void:
	if label:
		label.visible = false

func interact() -> bool:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player or not ("inventory" in player and player.inventory != null):
		return false

	var inv: Inventory = player.inventory

	# 1. Craft Flint and Steel if player has an Iron Bar and Flint, and doesn't already have one
	if inv.has_item("Iron Bar", 1) and inv.has_item("Flint", 1) and not inv.has_item("Flint and Steel", 1):
		inv.remove_item("Iron Bar", 1)
		inv.remove_item("Flint", 1)
		inv.add_item("Flint and Steel", 1)
		_show_dialogue("Furnace: Crafted Flint and Steel using 1 Iron Bar and 1 Flint!")
		_play_juice()
		return true

	# 2. Smelt Iron Ore into Iron Bar (requires 2 Iron Ore)
	if inv.has_item("Iron Ore", 2):
		inv.remove_item("Iron Ore", 2)
		inv.add_item("Iron Bar", 1)
		_show_dialogue("Furnace: Smelted 2 Iron Ore into 1 Iron Bar!")
		_play_juice()
		return true

	# 3. Fallback: single Iron Ore smelting if player only has 1
	if inv.has_item("Iron Ore", 1):
		inv.remove_item("Iron Ore", 1)
		inv.add_item("Iron Bar", 1)
		_show_dialogue("Furnace: Smelted 1 Iron Ore into 1 Iron Bar!")
		_play_juice()
		return true

	# 4. If player has no materials to smelt or craft, show helpful instructions
	_show_dialogue("Furnace Recipes:\n• 2 Iron Ore → 1 Iron Bar\n• 1 Iron Bar + 1 Flint → Flint and Steel")
	return false

func _play_juice() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.15, 0.85), 0.08)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.12)
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_mine"):
		am.play_mine()

func _show_dialogue(text: String) -> void:
	print(text)
	if label:
		label.text = text
		label.visible = true
		var timer = get_tree().create_timer(3.5)
		timer.timeout.connect(func(): if label: label.visible = false)
