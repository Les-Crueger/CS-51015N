extends StaticBody2D

@export var text: String = "You warmed your hands by the bonfire!"
@export var requires_item: String = "Flint and Steel"
@export var locked_message: String = "You need a Flint and Steel or Match to light up the bonfire."

var is_lit: bool = false
@onready var label: Label = get_node_or_null("Label")

func _ready() -> void:
	if not label:
		label = Label.new()
		label.name = "Label"
		label.visible = false
		label.offset_left = -110.0
		label.offset_top = -45.0
		label.offset_right = 110.0
		label.offset_bottom = -25.0
		label.add_theme_font_size_override("font_size", 9)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		add_child(label)
	else:
		label.visible = false

func interact() -> bool:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	if requires_item != "" and not is_lit:
		var has_req := false
		if player and "inventory" in player and player.inventory != null:
			has_req = player.inventory.has_item("Flint and Steel") or player.inventory.has_item("Match")
		if player and player.get("admin_key_override") == true:
			has_req = true
			
		if not has_req:
			_show_dialogue(locked_message)
			return false

		# Lit for the first time
		is_lit = true
		GameState.lit_bonfires_count += 1
		
		# Play ignition juice
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
		tween.tween_property(self, "scale", Vector2.ONE, 0.1)
		
		if GameState.lit_bonfires_count >= 2:
			_show_dialogue("Bonfire lit! (2/2)\nThe cave exit to Map 3 is now unsealed!")
		else:
			_show_dialogue("You lit the bonfire! (Lit: %d/2)" % GameState.lit_bonfires_count)
		return true

	# Already lit
	_show_dialogue(text)
	var tween = create_tween()
	scale = Vector2.ONE
	tween.tween_property(self, "scale", Vector2(1.15, 0.85), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	return true

func _show_dialogue(msg: String) -> void:
	print(msg)
	if label:
		label.text = msg
		label.visible = true
		var timer = get_tree().create_timer(3.5)
		timer.timeout.connect(func(): if label: label.visible = false)
