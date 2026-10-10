extends StaticBody2D

# ─────────────────────────────────────────────
# Rock type — set this in the Godot Inspector per rock instance!
# ─────────────────────────────────────────────
enum RockType { SMALL_ROCKS, IRON_DEPOSIT, COAL_DEPOSIT, GOLD_DEPOSIT }

@export var rock_type: RockType = RockType.SMALL_ROCKS
@export var mine_cooldown: float = 0.7  # seconds before this rock can be mined again

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var interact_area: Area2D = $InteractArea

var is_mining: bool = false

# ─────────────────────────────────────────────
# Drop tables: each entry is { item, min, max, chance (0-1) }
# ─────────────────────────────────────────────
const DROP_TABLES := {
	RockType.SMALL_ROCKS: [
		{ "item": "Rocks",    "min": 1, "max": 3, "chance": 1.0  },  # always drops
		{ "item": "Flint",    "min": 1, "max": 2, "chance": 0.40 },  # 40% chance
		{ "item": "Coal",     "min": 1, "max": 1, "chance": 0.15 },  # 15% chance
	],
	RockType.IRON_DEPOSIT: [
		{ "item": "Iron Ore", "min": 1, "max": 3, "chance": 1.0  },  # always drops
		{ "item": "Rocks",   "min": 1, "max": 2, "chance": 0.60 },  # 60% chance
		{ "item": "Flint",   "min": 1, "max": 1, "chance": 0.20 },  # 20% chance
		{ "item": "Coal",    "min": 1, "max": 2, "chance": 0.25 },  # 25% chance
	],
	RockType.COAL_DEPOSIT: [
		{ "item": "Coal",     "min": 2, "max": 4, "chance": 1.0  },  # always drops
		{ "item": "Rocks",   "min": 1, "max": 2, "chance": 0.50 },  # 50% chance
		{ "item": "Iron Ore","min": 1, "max": 1, "chance": 0.10 },  # 10% rare
	],
	RockType.GOLD_DEPOSIT: [
		{ "item": "Gold Ore", "min": 1, "max": 2, "chance": 1.0  },  # always drops
		{ "item": "Iron Ore","min": 1, "max": 2, "chance": 0.40 },  # 40% chance
		{ "item": "Rocks",   "min": 1, "max": 2, "chance": 0.70 },  # 70% chance
		{ "item": "Coal",    "min": 1, "max": 1, "chance": 0.30 },  # 30% chance
	],
}

func _ready() -> void:
	if label:
		label.visible = false

func interact() -> void:
	if is_mining:
		return

	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return

	# Require Pickaxe
	var has_pickaxe: bool = false
	if player.get("admin_key_override") == true:
		has_pickaxe = true
	elif "inventory" in player and player.inventory != null:
		has_pickaxe = player.inventory.has_item("Pickaxe")

	if not has_pickaxe:
		_show_dialogue("You need a Pickaxe to mine!")
		return

	is_mining = true

	# Hit animation
	if player.has_method("play_oneshot"):
		player.play_oneshot("hit")

	# Mining SFX
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_mine"):
		am.play_mine()

	# Rock shake juice
	var tween = create_tween()
	tween.tween_property(sprite, "position:x",  3.0, 0.04)
	tween.tween_property(sprite, "position:x", -3.0, 0.04)
	tween.tween_property(sprite, "position:x",  0.0, 0.04)
	
	# Add screen shake and hit-stop
	if player.has_method("add_screen_shake"):
		player.add_screen_shake(4.0)
	if player.has_method("hit_stop"):
		player.hit_stop(30) # 30ms hit pause

	# Roll the drop table
	var drops := _roll_drops()
	if "inventory" in player and player.inventory != null:
		for drop in drops:
			player.inventory.add_item(drop["item"], drop["amount"])

	# Build readable drop message
	if drops.is_empty():
		_show_dialogue("Nothing found this time...")
	else:
		var parts: Array = []
		for d in drops:
			parts.append("+%d %s" % [d["amount"], d["item"]])
		_show_dialogue(" | ".join(parts))

	var timer = get_tree().create_timer(mine_cooldown)
	timer.timeout.connect(func(): is_mining = false)

func _roll_drops() -> Array:
	var table: Array = DROP_TABLES.get(rock_type, [])
	var results: Array = []
	for entry in table:
		if randf() <= entry["chance"]:
			var amount: int = randi_range(entry["min"], entry["max"])
			results.append({ "item": entry["item"], "amount": amount })
	return results

func _show_dialogue(text: String) -> void:
	print(text)
	if label:
		label.text = text
		label.visible = true
		
		# Juice: Tween popup
		label.position.y = -20 # start a bit lower
		label.modulate.a = 0.0
		var tween = create_tween().set_parallel(true)
		tween.tween_property(label, "position:y", -40.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(label, "modulate:a", 1.0, 0.2)
		
		var timer = get_tree().create_timer(3.0)
		timer.timeout.connect(func():
			if label:
				var fade_out = create_tween()
				fade_out.tween_property(label, "modulate:a", 0.0, 0.2)
				fade_out.finished.connect(func(): label.visible = false)
		)
