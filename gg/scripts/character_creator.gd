extends Control

# ─── SPRITESHEET SETUP ────────────────────────────────────────────────────────
# Using the 2k version (2560×5120) for crisp display. Tiles are 160×160 each.
# Regular version (256×512) has 16×16 tiles — same layout, just smaller.
const SHEET_PATH = "res://assets/Customizable 2D Pixel Character Spritesheet/Customizable 2D Pixel Character Spritesheet 2k.png"
const TILE := 160  # px per tile in the 2k sheet

# ─── FACE OPTIONS (Row 0 front-facing heads — every 2nd col is a different character) ──
# Rect2(col * TILE, row * TILE, TILE, TILE)
var FACE_OPTIONS := [
	Rect2(0  * TILE, 0 * TILE, TILE, TILE),  # Light skin human
	Rect2(2  * TILE, 0 * TILE, TILE, TILE),  # Brown skin
	Rect2(4  * TILE, 0 * TILE, TILE, TILE),  # Redhead
	Rect2(6  * TILE, 0 * TILE, TILE, TILE),  # Green (Goblin)
	Rect2(8  * TILE, 0 * TILE, TILE, TILE),  # Purple (Elf)
	Rect2(10 * TILE, 0 * TILE, TILE, TILE),  # Light pink
	Rect2(12 * TILE, 0 * TILE, TILE, TILE),  # Robot/Skull
	Rect2(14 * TILE, 0 * TILE, TILE, TILE),  # Pale / Undead
]

# ─── HAIR OPTIONS (Rows 8, 10, 12 — multiple colors and styles) ─────────────
var HAIR_OPTIONS := [
	Rect2(-1, -1, 0, 0),                      # Bald / No hair
	Rect2(0  * TILE, 8  * TILE, TILE, TILE),  # Short Brown
	Rect2(2  * TILE, 8  * TILE, TILE, TILE),  # Spiky Brown
	Rect2(4  * TILE, 8  * TILE, TILE, TILE),  # Long Brown
	Rect2(6  * TILE, 8  * TILE, TILE, TILE),  # Auburn Ponytail
	Rect2(8  * TILE, 8  * TILE, TILE, TILE),  # Auburn Wavy
	Rect2(0  * TILE, 10 * TILE, TILE, TILE),  # Blonde Short
	Rect2(2  * TILE, 10 * TILE, TILE, TILE),  # Blonde Bob
	Rect2(4  * TILE, 10 * TILE, TILE, TILE),  # Blonde Long
	Rect2(6  * TILE, 10 * TILE, TILE, TILE),  # Silver/Grey Short
	Rect2(8  * TILE, 10 * TILE, TILE, TILE),  # Silver/Grey Long
	Rect2(10 * TILE, 10 * TILE, TILE, TILE),  # Jet Black Spiky
	Rect2(12 * TILE, 10 * TILE, TILE, TILE),  # Jet Black Long
	Rect2(0  * TILE, 12 * TILE, TILE, TILE),  # Midnight Blue
	Rect2(4  * TILE, 12 * TILE, TILE, TILE),  # Forest Green
	Rect2(12 * TILE, 12 * TILE, TILE, TILE),  # Pure White
]

# ─── OUTFIT OPTIONS (Rows 16-20 — fully clothed tunics, armor, robes, shirts) ──
var OUTFIT_OPTIONS := [
	Rect2(0  * TILE, 16 * TILE, TILE, TILE),  # Grey Tunic
	Rect2(1  * TILE, 16 * TILE, TILE, TILE),  # Leather Vest
	Rect2(2  * TILE, 16 * TILE, TILE, TILE),  # Brown Hunter Garb
	Rect2(3  * TILE, 16 * TILE, TILE, TILE),  # Blue Traveler Vest
	Rect2(4  * TILE, 16 * TILE, TILE, TILE),  # Royal White Tunic
	Rect2(5  * TILE, 16 * TILE, TILE, TILE),  # Golden Silk Robe
	Rect2(12 * TILE, 16 * TILE, TILE, TILE),  # Black Knight Plate
	Rect2(14 * TILE, 16 * TILE, TILE, TILE),  # Dark Rogue Leather
	Rect2(0  * TILE, 17 * TILE, TILE, TILE),  # Crimson Mage Robe
	Rect2(2  * TILE, 17 * TILE, TILE, TILE),  # Velvet Aristocrat Coat
	Rect2(4  * TILE, 17 * TILE, TILE, TILE),  # Amber Trader Tunic
	Rect2(12 * TILE, 17 * TILE, TILE, TILE),  # Shadow Assassin Shroud
	Rect2(0  * TILE, 18 * TILE, TILE, TILE),  # Formal Black Vest
	Rect2(4  * TILE, 18 * TILE, TILE, TILE),  # Burgundy Squire Garb
	Rect2(10 * TILE, 18 * TILE, TILE, TILE),  # Winter Wool Coat
	Rect2(12 * TILE, 18 * TILE, TILE, TILE),  # Navy Guard Uniform
	Rect2(0  * TILE, 20 * TILE, TILE, TILE),  # Scarlet Champion Plate
	Rect2(8  * TILE, 20 * TILE, TILE, TILE),  # Cobalt Wizard Robe
	Rect2(10 * TILE, 20 * TILE, TILE, TILE),  # Forest Ranger Mail
]

# ─── STATE ────────────────────────────────────────────────────────────────────
var sheet_tex: Texture2D
var face_idx: int = 0
var hair_idx: int = 0
var outfit_idx: int = 0

# ─── NODES ────────────────────────────────────────────────────────────────────
var preview_face: TextureRect
var preview_hair: TextureRect
var preview_outfit: TextureRect
var face_label: Label
var hair_label: Label
var outfit_label: Label

func _ready() -> void:
	sheet_tex = load(SHEET_PATH)
	_build_ui()
	_update_preview()

func _build_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Main vertical layout
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 10)
	add_child(main_vbox)
	
	# Add some top margin
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 30
	main_vbox.add_child(spacer)
	
	# Title
	var title = Label.new()
	title.text = "CREATE YOUR CHARACTER"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	main_vbox.add_child(title)
	
	# Center HBox: left (options) + right (preview)
	var center_hbox = HBoxContainer.new()
	center_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_hbox.add_theme_constant_override("separation", 40)
	center_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(center_hbox)
	
	# ── LEFT: Selection controls ──
	var left_vbox = VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 14)
	left_vbox.custom_minimum_size.x = 400
	center_hbox.add_child(left_vbox)
	
	# Face selector
	face_label = Label.new()
	_add_selector(left_vbox, "FACE", face_label, "_on_face_prev", "_on_face_next")
	
	# Hair selector
	hair_label = Label.new()
	_add_selector(left_vbox, "HAIR", hair_label, "_on_hair_prev", "_on_hair_next")
	
	# Outfit selector
	outfit_label = Label.new()
	_add_selector(left_vbox, "OUTFIT", outfit_label, "_on_outfit_prev", "_on_outfit_next")
	
	# ── RIGHT: Preview ──
	var preview_panel = PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(200, 200)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.14, 0.2, 0.9)
	style.border_color = Color(0.4, 0.5, 0.7, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	preview_panel.add_theme_stylebox_override("panel", style)
	center_hbox.add_child(preview_panel)
	
	var preview_center = CenterContainer.new()
	preview_center.custom_minimum_size = Vector2(200, 200)
	preview_panel.add_child(preview_center)
	
	# Stack layers: outfit (back, lower) → face (centered) → hair (front, top)
	var preview_stack = Control.new()
	preview_stack.custom_minimum_size = Vector2(128, 148)
	preview_center.add_child(preview_stack)
	
	preview_outfit = TextureRect.new()
	preview_outfit.custom_minimum_size = Vector2(128, 128)
	preview_outfit.position = Vector2(0, 24)
	preview_outfit.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview_outfit.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_stack.add_child(preview_outfit)
	
	preview_face = TextureRect.new()
	preview_face.custom_minimum_size = Vector2(128, 128)
	preview_face.position = Vector2(0, 0)
	preview_face.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview_face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_stack.add_child(preview_face)
	
	preview_hair = TextureRect.new()
	preview_hair.custom_minimum_size = Vector2(128, 128)
	preview_hair.position = Vector2(0, 0)
	preview_hair.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview_hair.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_stack.add_child(preview_hair)
	
	# Preview label
	var preview_label = Label.new()
	preview_label.text = "Preview"
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.add_theme_font_size_override("font_size", 12)
	preview_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	
	var preview_vbox = VBoxContainer.new()
	preview_vbox.add_theme_constant_override("separation", 4)
	# Re-parent preview_panel into a vbox with label
	center_hbox.remove_child(preview_panel)
	preview_vbox.add_child(preview_panel)
	preview_vbox.add_child(preview_label)
	center_hbox.add_child(preview_vbox)
	
	# ── START BUTTON ──
	var btn_container = CenterContainer.new()
	btn_container.custom_minimum_size.y = 60
	main_vbox.add_child(btn_container)
	
	var start_btn = Button.new()
	start_btn.text = "  START GAME  "
	start_btn.add_theme_font_size_override("font_size", 18)
	start_btn.pressed.connect(_on_start_pressed)
	btn_container.add_child(start_btn)

func _add_selector(parent: VBoxContainer, category: String, value_label: Label, prev_fn: String, next_fn: String) -> void:
	var cat_label = Label.new()
	cat_label.text = category
	cat_label.add_theme_font_size_override("font_size", 14)
	cat_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.9))
	parent.add_child(cat_label)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	parent.add_child(hbox)
	
	var prev_btn = Button.new()
	prev_btn.text = " < "
	prev_btn.add_theme_font_size_override("font_size", 16)
	prev_btn.pressed.connect(Callable(self, prev_fn))
	hbox.add_child(prev_btn)
	
	# Show a preview of the current option
	value_label.text = "1"
	value_label.add_theme_font_size_override("font_size", 16)
	value_label.custom_minimum_size.x = 60
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(value_label)
	
	var next_btn = Button.new()
	next_btn.text = " > "
	next_btn.add_theme_font_size_override("font_size", 16)
	next_btn.pressed.connect(Callable(self, next_fn))
	hbox.add_child(next_btn)

# ─── NAVIGATION CALLBACKS ────────────────────────────────────────────────────

func _on_face_prev() -> void:
	face_idx = wrapi(face_idx - 1, 0, FACE_OPTIONS.size())
	_update_preview()

func _on_face_next() -> void:
	face_idx = wrapi(face_idx + 1, 0, FACE_OPTIONS.size())
	_update_preview()

func _on_hair_prev() -> void:
	hair_idx = wrapi(hair_idx - 1, 0, HAIR_OPTIONS.size())
	_update_preview()

func _on_hair_next() -> void:
	hair_idx = wrapi(hair_idx + 1, 0, HAIR_OPTIONS.size())
	_update_preview()

func _on_outfit_prev() -> void:
	outfit_idx = wrapi(outfit_idx - 1, 0, OUTFIT_OPTIONS.size())
	_update_preview()

func _on_outfit_next() -> void:
	outfit_idx = wrapi(outfit_idx + 1, 0, OUTFIT_OPTIONS.size())
	_update_preview()

# ─── PREVIEW UPDATE ──────────────────────────────────────────────────────────

func _update_preview() -> void:
	face_label.text = str(face_idx + 1) + "/" + str(FACE_OPTIONS.size())
	hair_label.text = str(hair_idx + 1) + "/" + str(HAIR_OPTIONS.size())
	outfit_label.text = str(outfit_idx + 1) + "/" + str(OUTFIT_OPTIONS.size())
	
	# Face
	var face_atlas = AtlasTexture.new()
	face_atlas.atlas = sheet_tex
	face_atlas.region = FACE_OPTIONS[face_idx]
	preview_face.texture = face_atlas
	
	# Hair
	var hair_region = HAIR_OPTIONS[hair_idx]
	if hair_region.position.x < 0:
		preview_hair.texture = null
	else:
		var hair_atlas = AtlasTexture.new()
		hair_atlas.atlas = sheet_tex
		hair_atlas.region = hair_region
		preview_hair.texture = hair_atlas
	
	# Outfit
	var outfit_atlas = AtlasTexture.new()
	outfit_atlas.atlas = sheet_tex
	outfit_atlas.region = OUTFIT_OPTIONS[outfit_idx]
	preview_outfit.texture = outfit_atlas

# ─── START GAME ──────────────────────────────────────────────────────────────

func _on_start_pressed() -> void:
	# Save choices to GameState
	GameState.avatar_face_index = face_idx
	GameState.avatar_hair_index = hair_idx
	GameState.avatar_outfit_index = outfit_idx
	GameState.avatar_created = true
	GameState.save_to_disk()
	
	# Transition to first map
	SceneTransition.change_scene_with_loading(get_tree(), "res://scenes/firstmap.tscn", Vector2.ZERO, false)
