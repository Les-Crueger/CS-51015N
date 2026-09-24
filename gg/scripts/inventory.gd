extends Node
class_name Inventory

signal inventory_updated

@export var max_slots: int = 10
var slots: Array = []

func _ready() -> void:
	# Initialize empty inventory slots
	for i in range(max_slots):
		slots.append({"item_name": "", "amount": 0, "icon": ""})

func add_item(item_name: String, amount: int = 1, icon_path: String = "") -> bool:
	# 1. Try to stack into existing slot
	for slot in slots:
		if slot["item_name"] == item_name:
			slot["amount"] += amount
			inventory_updated.emit()
			return true

	# 2. Find first empty slot
	for slot in slots:
		if slot["item_name"] == "":
			slot["item_name"] = item_name
			slot["amount"] = amount
			slot["icon"] = icon_path
			inventory_updated.emit()
			return true

	print("Inventory is full!")
	return false

func remove_item(item_name: String, amount: int = 1) -> bool:
	for slot in slots:
		if slot["item_name"] == item_name:
			if slot["amount"] >= amount:
				slot["amount"] -= amount
				if slot["amount"] <= 0:
					slot["item_name"] = ""
					slot["amount"] = 0
					slot["icon"] = ""
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
