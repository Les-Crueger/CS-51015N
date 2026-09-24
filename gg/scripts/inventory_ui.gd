extends CanvasLayer

@onready var grid_container: GridContainer = $Control/PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var title_label: Label = $Control/PanelContainer/MarginContainer/VBoxContainer/TitleLabel

var slot_scene = preload("res://scenes/inventory_slot_ui.tscn")
var inventory: Inventory = null

func _ready() -> void:
	# Hide overlay initially
	visible = true

func setup(inv: Inventory) -> void:
	inventory = inv
	if inventory:
		inventory.inventory_updated.connect(update_ui)
		update_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_I or event.keycode == KEY_TAB:
			$Control.visible = not $Control.visible

func update_ui() -> void:
	if not inventory:
		return

	# Clear existing slots
	for child in grid_container.get_children():
		child.queue_free()

	# Populate slot UI nodes
	for slot in inventory.slots:
		var slot_ui = slot_scene.instantiate()
		grid_container.add_child(slot_ui)
		slot_ui.set_slot(slot["item_name"], slot["amount"], slot["icon"])
