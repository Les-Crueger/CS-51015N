extends Node
class_name Inventory

signal inventory_updated

@export var max_slots: int = 10
var slots: Array = []

func _ready() -> void:
	# Initialize empty inventory slots (with durability fields)
	for i in range(max_slots):
		slots.append({"item_name": "", "amount": 0, "icon": "", "durability": -1, "max_durability": -1})
		
	inventory_updated.connect(func(): GameState.save_inventory(slots))

	# Restore state if previously saved across level transition
	if GameState.is_inventory_saved:
		GameState.load_inventory(self)

const ITEM_ICONS := {
	"Fish":             "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_1.png",
	"Fishing Rod":      "res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/cache/017-25-1-icon.png",
	"Iron Fishing Rod": "res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/cache/017-25-1-icon.png",
	"Pickaxe":          "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_103.png",
	"Iron Pickaxe":     "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_103.png",
	"Gold Pickaxe":     "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_103.png",
	"Rocks":            "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_81.png",
	"Rock":             "res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/cache/017-20-1-icon.png",
	"Wood":             "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_77.png",
	"Iron Ore":         "res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/cache/017-23-2-icon.png",
	"Coal":             "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_83.png",
	"Flint":            "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_82.png",
	"Gold Ore":         "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_85.png",
	"Iron Bar":         "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_97.png",
	"Gold Ingot":       "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_98.png",
	"Flint and Steel":  "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_104.png",
	"Level 2 Key":      "res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/cache/017-41-1-icon.png",
	"Level 3 Key":      "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_101.png",
}

# ─── Tool durability items ────────────────────────────────────────────────────
const TOOL_ITEMS: Array = ["Pickaxe", "Iron Pickaxe", "Gold Pickaxe", "Fishing Rod", "Iron Fishing Rod"]

func add_item(item_name: String, amount: int = 1, icon_data: Variant = "", durability: int = -1, max_durability: int = -1) -> bool:
	if typeof(icon_data) == TYPE_STRING and (icon_data == "" or icon_data == "res://icon.svg"):
		if ITEM_ICONS.has(item_name):
			icon_data = ITEM_ICONS[item_name]

	# 1. Try to stack into existing slot (non-tools only — tools track durability individually)
	if item_name not in TOOL_ITEMS:
		for slot in slots:
			if slot["item_name"] == item_name:
				slot["amount"] += amount
				if typeof(slot["icon"]) == TYPE_STRING and (slot["icon"] == "" or slot["icon"] == "res://icon.svg"):
					slot["icon"] = icon_data
				inventory_updated.emit()
				return true

	# 2. Find first empty slot
	for slot in slots:
		if slot["item_name"] == "":
			slot["item_name"] = item_name
			slot["amount"] = amount
			slot["icon"] = icon_data
			slot["durability"] = durability
			slot["max_durability"] = max_durability
			inventory_updated.emit()
			return true

	print("Inventory is full!")
	return false

# Convenience wrapper used by Stone Forger NPC
func add_item_with_durability(item_name: String, amount: int = 1, durability: int = -1) -> bool:
	return add_item(item_name, amount, "", durability, durability)

# Consume one use from a tool's durability
func use_tool(item_name: String) -> void:
	for slot in slots:
		if slot["item_name"] == item_name:
			if slot.get("durability", -1) > 0:
				slot["durability"] -= 1
				if slot["durability"] <= 0:
					remove_item(item_name, 1)
					print(item_name, " broke!")
					return
			inventory_updated.emit()
			return

func remove_item(item_name: String, amount: int = 1) -> bool:
	for slot in slots:
		if slot["item_name"] == item_name:
			if slot["amount"] >= amount:
				slot["amount"] -= amount
				if slot["amount"] <= 0:
					slot["item_name"] = ""
					slot["amount"] = 0
					slot["icon"] = ""
					slot["durability"] = -1
					slot["max_durability"] = -1
				inventory_updated.emit()
				return true
	return false

func get_item_count(item_name: String) -> int:
	var total = 0
	for slot in slots:
		if slot["item_name"] == item_name:
			total += slot["amount"]
	return total

func has_item(item_name: String, amount: int = 1) -> bool:
	return get_item_count(item_name) >= amount
