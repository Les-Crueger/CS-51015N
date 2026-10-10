extends StaticBody2D

@export var npc_name: String = "Stone the Forger"

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var interact_area: Area2D = $InteractArea

var tex_stone = preload("res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/cache/046-1-1.png")

# ─── Forge Recipes ────────────────────────────────────────────────────────────
# inputs: list of {item, amount}
# output_durability: -1 means non-tool (no bar shown), > 0 sets starting durability
const RECIPES: Array = [
	{
		"name": "Smelt Iron Bar",
		"inputs": [{"item": "Iron Ore", "amount": 2}],
		"output_item": "Iron Bar", "output_amount": 1, "output_durability": -1
	},
	{
		"name": "Smelt Gold Ingot",
		"inputs": [{"item": "Gold Ore", "amount": 2}],
		"output_item": "Gold Ingot", "output_amount": 1, "output_durability": -1
	},
	{
		"name": "Forge Iron Pickaxe",
		"inputs": [{"item": "Iron Bar", "amount": 3}, {"item": "Wood", "amount": 2}],
		"output_item": "Iron Pickaxe", "output_amount": 1, "output_durability": 60
	},
	{
		"name": "Forge Gold Pickaxe",
		"inputs": [{"item": "Gold Ingot", "amount": 3}, {"item": "Wood", "amount": 2}],
		"output_item": "Gold Pickaxe", "output_amount": 1, "output_durability": 100
	},
	{
		"name": "Forge Iron Fishing Rod",
		"inputs": [{"item": "Iron Bar", "amount": 2}, {"item": "Wood", "amount": 3}],
		"output_item": "Iron Fishing Rod", "output_amount": 1, "output_durability": 50
	},
]

var current_player = null

func _ready() -> void:
	if label:
		label.visible = false
	if sprite:
		sprite.texture = tex_stone
		sprite.region_enabled = false
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		current_player = body
		_show_label("Press E to talk to Stone")

func _on_body_exited(body: Node2D) -> void:
	if body == current_player:
		current_player = null
		if label:
			label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		if current_player:
			interact()

func interact() -> void:
	var player = current_player
	if not player or not ("inventory" in player) or player.inventory == null:
		_show_label("You have no inventory!")
		return

	var inv: Inventory = player.inventory

	# Jump / anvil-hit juice
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "position:y", -5.0, 0.08)
		tween.tween_property(sprite, "position:y",  0.0, 0.08)

	# Try each recipe — do the first one the player can afford
	for recipe in RECIPES:
		var can_craft := true
		for inp in recipe["inputs"]:
			if not inv.has_item(inp["item"], inp["amount"]):
				can_craft = false
				break

		if can_craft:
			for inp in recipe["inputs"]:
				inv.remove_item(inp["item"], inp["amount"])

			var dur: int = recipe.get("output_durability", -1)
			if inv.has_method("add_item_with_durability"):
				inv.add_item_with_durability(recipe["output_item"], recipe["output_amount"], dur)
			else:
				inv.add_item(recipe["output_item"], recipe["output_amount"])

			_show_label("Stone: Forged " + recipe["output_item"] + "! \uD83D\uDD28")
			if get_node_or_null("/root/AudioManager"):
				AudioManager.play_mine()
			return

	# Nothing crafted — show recipe guide
	_show_label("Stone: What do you need?\n" + _recipe_hint())

func _recipe_hint() -> String:
	var lines := []
	for recipe in RECIPES:
		var parts := []
		for inp in recipe["inputs"]:
			parts.append(str(inp["amount"]) + "x " + inp["item"])
		lines.append(recipe["name"] + ": " + ", ".join(parts))
	return "\n".join(lines)

func _show_label(text: String) -> void:
	if not label:
		return
	label.text = text
	label.visible = true
	label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.2)
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(func():
		if label:
			var fade = create_tween()
			fade.tween_property(label, "modulate:a", 0.0, 0.3)
			fade.finished.connect(func(): if label: label.visible = false)
	)
