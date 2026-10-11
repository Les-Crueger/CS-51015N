extends CanvasLayer

const SHEET_PATH = "res://assets/Customizable 2D Pixel Character Spritesheet/Customizable 2D Pixel Character Spritesheet 2k.png"
const TILE := 160

var FACE_OPTIONS := [
	Rect2(0  * TILE, 0 * TILE, TILE, TILE),
	Rect2(2  * TILE, 0 * TILE, TILE, TILE),
	Rect2(4  * TILE, 0 * TILE, TILE, TILE),
	Rect2(6  * TILE, 0 * TILE, TILE, TILE),
	Rect2(8  * TILE, 0 * TILE, TILE, TILE),
	Rect2(10 * TILE, 0 * TILE, TILE, TILE),
	Rect2(12 * TILE, 0 * TILE, TILE, TILE),
	Rect2(14 * TILE, 0 * TILE, TILE, TILE),
]

var HAIR_OPTIONS := [
	Rect2(-1, -1, 0, 0),
	Rect2(0  * TILE, 8  * TILE, TILE, TILE),
	Rect2(2  * TILE, 8  * TILE, TILE, TILE),
	Rect2(4  * TILE, 8  * TILE, TILE, TILE),
	Rect2(6  * TILE, 8  * TILE, TILE, TILE),
	Rect2(8  * TILE, 8  * TILE, TILE, TILE),
	Rect2(0  * TILE, 10 * TILE, TILE, TILE),
	Rect2(2  * TILE, 10 * TILE, TILE, TILE),
	Rect2(4  * TILE, 10 * TILE, TILE, TILE),
	Rect2(6  * TILE, 10 * TILE, TILE, TILE),
	Rect2(8  * TILE, 10 * TILE, TILE, TILE),
	Rect2(10 * TILE, 10 * TILE, TILE, TILE),
	Rect2(12 * TILE, 10 * TILE, TILE, TILE),
	Rect2(0  * TILE, 12 * TILE, TILE, TILE),
	Rect2(4  * TILE, 12 * TILE, TILE, TILE),
	Rect2(12 * TILE, 12 * TILE, TILE, TILE),
]

var OUTFIT_OPTIONS := [
	Rect2(0  * TILE, 16 * TILE, TILE, TILE),
	Rect2(1  * TILE, 16 * TILE, TILE, TILE),
	Rect2(2  * TILE, 16 * TILE, TILE, TILE),
	Rect2(3  * TILE, 16 * TILE, TILE, TILE),
	Rect2(4  * TILE, 16 * TILE, TILE, TILE),
	Rect2(5  * TILE, 16 * TILE, TILE, TILE),
	Rect2(12 * TILE, 16 * TILE, TILE, TILE),
	Rect2(14 * TILE, 16 * TILE, TILE, TILE),
	Rect2(0  * TILE, 17 * TILE, TILE, TILE),
	Rect2(2  * TILE, 17 * TILE, TILE, TILE),
	Rect2(4  * TILE, 17 * TILE, TILE, TILE),
	Rect2(12 * TILE, 17 * TILE, TILE, TILE),
	Rect2(0  * TILE, 18 * TILE, TILE, TILE),
	Rect2(4  * TILE, 18 * TILE, TILE, TILE),
	Rect2(10 * TILE, 18 * TILE, TILE, TILE),
	Rect2(12 * TILE, 18 * TILE, TILE, TILE),
	Rect2(0  * TILE, 20 * TILE, TILE, TILE),
	Rect2(8  * TILE, 20 * TILE, TILE, TILE),
	Rect2(10 * TILE, 20 * TILE, TILE, TILE),
]

var preview_face: TextureRect
var preview_hair: TextureRect
var preview_outfit: TextureRect

func _ready() -> void:
	layer = 8
	_build_hud()

func _build_hud() -> void:
	var hud_root = Control.new()
	hud_root.set_anchors_preset(Control.PRESET_TOP_LEFT)
	hud_root.position = Vector2(16, 16)
	add_child(hud_root)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(64, 64)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.10, 0.16, 0.85)
	sb.border_color = Color(0.4, 0.55, 0.75, 0.9)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", sb)
	hud_root.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	var stack = Control.new()
	stack.custom_minimum_size = Vector2(56, 56)
	margin.add_child(stack)

	preview_outfit = TextureRect.new()
	preview_outfit.custom_minimum_size = Vector2(56, 56)
	preview_outfit.position = Vector2(0, 10)
	preview_outfit.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview_outfit.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stack.add_child(preview_outfit)

	preview_face = TextureRect.new()
	preview_face.custom_minimum_size = Vector2(56, 56)
	preview_face.position = Vector2(0, 0)
	preview_face.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview_face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stack.add_child(preview_face)

	preview_hair = TextureRect.new()
	preview_hair.custom_minimum_size = Vector2(56, 56)
	preview_hair.position = Vector2(0, 0)
	preview_hair.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview_hair.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stack.add_child(preview_hair)

	update_avatar()

func update_avatar() -> void:
	if not ResourceLoader.exists(SHEET_PATH) and not FileAccess.file_exists(SHEET_PATH):
		return
	var tex = load(SHEET_PATH)
	if not tex:
		return

	var f_idx = clampi(GameState.avatar_face_index, 0, FACE_OPTIONS.size() - 1)
	var h_idx = clampi(GameState.avatar_hair_index, 0, HAIR_OPTIONS.size() - 1)
	var o_idx = clampi(GameState.avatar_outfit_index, 0, OUTFIT_OPTIONS.size() - 1)

	# Face
	var f_atlas = AtlasTexture.new()
	f_atlas.atlas = tex
	f_atlas.region = FACE_OPTIONS[f_idx]
	preview_face.texture = f_atlas

	# Hair
	var h_reg = HAIR_OPTIONS[h_idx]
	if h_reg.position.x < 0:
		preview_hair.texture = null
	else:
		var h_atlas = AtlasTexture.new()
		h_atlas.atlas = tex
		h_atlas.region = h_reg
		preview_hair.texture = h_atlas

	# Outfit
	var o_atlas = AtlasTexture.new()
	o_atlas.atlas = tex
	o_atlas.region = OUTFIT_OPTIONS[o_idx]
	preview_outfit.texture = o_atlas
