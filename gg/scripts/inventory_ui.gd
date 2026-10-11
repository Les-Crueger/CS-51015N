extends CanvasLayer

@export_group("Layout & Positioning")
@export var columns: int = 5
@export var slot_size: Vector2 = Vector2(36, 36)
@export var grid_separation: int = 4
@export var position_offset: Vector2 = Vector2(0, -15)

@export_group("Title Style")
@export var show_title: bool = true
@export var title_text: String = "INVENTORY (Press 'I' / TAB)"
@export var title_font_size: int = 12
@export var title_color: Color = Color(0.9, 0.95, 1.0)

@export_group("Main Panel Box Style")
@export var bg_color: Color = Color(0.08, 0.10, 0.15, 0.88)
@export var border_color: Color = Color(0.35, 0.45, 0.65, 0.95)
@export var border_width: int = 2
@export var corner_radius: int = 6

@export_group("Slot Style")
@export var slot_bg_color: Color = Color(0.15, 0.18, 0.24, 0.9)
@export var slot_border_color: Color = Color(0.4, 0.5, 0.7, 0.8)
@export var slot_border_width: int = 1
@export var slot_corner_radius: int = 4
@export var amount_font_size: int = 10
@export var amount_color: Color = Color(1.0, 1.0, 1.0)

@onready var control_node: Control = $Control
@onready var panel_container: PanelContainer = $Control/PanelContainer
@onready var grid_container: GridContainer = $Control/PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var title_label: Label = $Control/PanelContainer/MarginContainer/VBoxContainer/TitleLabel

var slot_scene = preload("res://scenes/inventory_slot_ui.tscn")
var inventory: Inventory = null
var _panel_base_pos: Vector2 = Vector2.ZERO
var _selected_item: String = ""

func set_active_item(item_name: String) -> void:
	_selected_item = item_name
	update_ui()

func _ready() -> void:
	visible = true
	_panel_base_pos = panel_container.position
	apply_custom_styles()

func apply_custom_styles() -> void:
	if not is_node_ready():
		return
		
	# Apply Main Panel Box Style
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = bg_color
	style_box.border_color = border_color
	style_box.set_border_width_all(border_width)
	style_box.set_corner_radius_all(corner_radius)
	panel_container.add_theme_stylebox_override("panel", style_box)

	# Title settings
	title_label.visible = show_title
	title_label.text = title_text
	title_label.add_theme_font_size_override("font_size", title_font_size)
	title_label.add_theme_color_override("font_color", title_color)

	_add_avatar_portrait()

func _add_avatar_portrait() -> void:
	var existing = title_label.get_parent().get_node_or_null("AvatarCard")
	if existing:
		return
	var card = HBoxContainer.new()
	card.name = "AvatarCard"
	card.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_theme_constant_override("separation", 8)
	title_label.get_parent().add_child(card)
	title_label.get_parent().move_child(card, 0) # Place at top

	var p_box = PanelContainer.new()
	p_box.custom_minimum_size = Vector2(40, 40)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.15, 0.22, 0.9)
	sb.border_color = Color(0.4, 0.55, 0.75, 0.9)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	p_box.add_theme_stylebox_override("panel", sb)
	card.add_child(p_box)

	var stack = Control.new()
	stack.custom_minimum_size = Vector2(36, 36)
	p_box.add_child(stack)

	var tex_path = "res://assets/Customizable 2D Pixel Character Spritesheet/Customizable 2D Pixel Character Spritesheet 2k.png"
	if ResourceLoader.exists(tex_path) or FileAccess.file_exists(tex_path):
		var tex = load(tex_path)
		var tile := 160
		var faces := [
			Rect2(0 * tile, 0, tile, tile), Rect2(2 * tile, 0, tile, tile),
			Rect2(4 * tile, 0, tile, tile), Rect2(6 * tile, 0, tile, tile),
			Rect2(8 * tile, 0, tile, tile), Rect2(10 * tile, 0, tile, tile),
			Rect2(12 * tile, 0, tile, tile), Rect2(14 * tile, 0, tile, tile)
		]
		var hairs := [
			Rect2(-1, -1, 0, 0),
			Rect2(0 * tile, 8 * tile, tile, tile), Rect2(2 * tile, 8 * tile, tile, tile),
			Rect2(4 * tile, 8 * tile, tile, tile), Rect2(6 * tile, 8 * tile, tile, tile),
			Rect2(8 * tile, 8 * tile, tile, tile), Rect2(0 * tile, 10 * tile, tile, tile),
			Rect2(2 * tile, 10 * tile, tile, tile), Rect2(4 * tile, 10 * tile, tile, tile),
			Rect2(6 * tile, 10 * tile, tile, tile), Rect2(8 * tile, 10 * tile, tile, tile),
			Rect2(10 * tile, 10 * tile, tile, tile), Rect2(12 * tile, 10 * tile, tile, tile),
			Rect2(0 * tile, 12 * tile, tile, tile), Rect2(4 * tile, 12 * tile, tile, tile),
			Rect2(12 * tile, 12 * tile, tile, tile)
		]
		var outfits := [
			Rect2(0 * tile, 16 * tile, tile, tile), Rect2(1 * tile, 16 * tile, tile, tile),
			Rect2(2 * tile, 16 * tile, tile, tile), Rect2(3 * tile, 16 * tile, tile, tile),
			Rect2(4 * tile, 16 * tile, tile, tile), Rect2(5 * tile, 16 * tile, tile, tile),
			Rect2(12 * tile, 16 * tile, tile, tile), Rect2(14 * tile, 16 * tile, tile, tile),
			Rect2(0 * tile, 17 * tile, tile, tile), Rect2(2 * tile, 17 * tile, tile, tile),
			Rect2(4 * tile, 17 * tile, tile, tile), Rect2(12 * tile, 17 * tile, tile, tile),
			Rect2(0 * tile, 18 * tile, tile, tile), Rect2(4 * tile, 18 * tile, tile, tile),
			Rect2(10 * tile, 18 * tile, tile, tile), Rect2(12 * tile, 18 * tile, tile, tile),
			Rect2(0 * tile, 20 * tile, tile, tile), Rect2(8 * tile, 20 * tile, tile, tile),
			Rect2(10 * tile, 20 * tile, tile, tile)
		]
		var f_idx = clampi(GameState.avatar_face_index, 0, faces.size() - 1)
		var h_idx = clampi(GameState.avatar_hair_index, 0, hairs.size() - 1)
		var o_idx = clampi(GameState.avatar_outfit_index, 0, outfits.size() - 1)

		var out_rect = TextureRect.new()
		out_rect.custom_minimum_size = Vector2(36, 36)
		out_rect.position = Vector2(0, 6)
		out_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		out_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var o_at = AtlasTexture.new()
		o_at.atlas = tex
		o_at.region = outfits[o_idx]
		out_rect.texture = o_at
		stack.add_child(out_rect)

		var face_rect = TextureRect.new()
		face_rect.custom_minimum_size = Vector2(36, 36)
		face_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		face_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var f_at = AtlasTexture.new()
		f_at.atlas = tex
		f_at.region = faces[f_idx]
		face_rect.texture = f_at
		stack.add_child(face_rect)

		if hairs[h_idx].position.x >= 0:
			var hair_rect = TextureRect.new()
			hair_rect.custom_minimum_size = Vector2(36, 36)
			hair_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			hair_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			var h_at = AtlasTexture.new()
			h_at.atlas = tex
			h_at.region = hairs[h_idx]
			hair_rect.texture = h_at
			stack.add_child(hair_rect)

	# Grid & separation
	grid_container.columns = columns
	grid_container.add_theme_constant_override("h_separation", grid_separation)
	grid_container.add_theme_constant_override("v_separation", grid_separation)

	# Position offset — always relative to original base position, never accumulates
	panel_container.position = _panel_base_pos + position_offset

func setup(inv: Inventory) -> void:
	inventory = inv
	if inventory:
		if not inventory.inventory_updated.is_connected(update_ui):
			inventory.inventory_updated.connect(update_ui)
		update_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_I or event.keycode == KEY_TAB:
			control_node.visible = not control_node.visible

func update_ui() -> void:
	if not inventory:
		return

	# NOTE: styles are applied once in _ready(); not repeated here to avoid drift.

	# Clear existing slots
	for child in grid_container.get_children():
		child.queue_free()

	# Populate slot UI nodes
	for slot in inventory.slots:
		var slot_ui = slot_scene.instantiate()
		grid_container.add_child(slot_ui)
		
		# Apply custom slot styling parameters
		if "slot_size" in slot_ui:
			slot_ui.custom_minimum_size = slot_size
		if slot_ui.has_method("apply_slot_style"):
			slot_ui.apply_slot_style(
				slot_bg_color,
				slot_border_color,
				slot_border_width,
				slot_corner_radius,
				amount_font_size,
				amount_color
			)
			
		var dur: int     = slot.get("durability",     -1)
		var max_dur: int = slot.get("max_durability", -1)
		slot_ui.set_slot(slot["item_name"], slot["amount"], slot["icon"], dur, max_dur)
		
		# Highlight the currently active / held item
		if slot["item_name"] != "" and slot["item_name"] == _selected_item:
			if slot_ui.has_method("set_selected"):
				slot_ui.set_selected(true)
