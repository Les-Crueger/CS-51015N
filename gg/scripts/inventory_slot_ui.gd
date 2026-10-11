extends PanelContainer

@onready var icon_rect: TextureRect = $MarginContainer/VBoxContainer/Icon
@onready var amount_label: Label = $MarginContainer/Amount
@onready var durability_bar: ProgressBar = $MarginContainer/VBoxContainer/DurabilityBar

var is_selected: bool = false

const ITEM_ICONS := {
	"Fish":             "res://assets/Hollow Dolphin Fishing Icon Pack/Separated Sprites/16x16/fishing_icons_16x16_1.png",
	"Fishing Rod":      "res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/cache/017-25-1-icon.png",
	"Iron Fishing Rod": "res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/cache/017-25-1-icon.png",
	"Pickaxe":          "res://assets/Shikashi's Fantasy Icons Pack v2/Shikashi's Fantasy Icons Pack v2/pickaxe.png",
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

# ─── Slot styling ─────────────────────────────────────────────────────────────

func apply_slot_style(bg_color: Color, border_color: Color, border_width: int, corner_radius: int, amount_font_size: int, amount_color: Color) -> void:
	_apply_panel_style(bg_color, border_color, border_width, corner_radius)
	if amount_label:
		amount_label.add_theme_font_size_override("font_size", amount_font_size)
		amount_label.add_theme_color_override("font_color", amount_color)

# Called by inventory_ui to mark the currently active/held item
func set_selected(selected: bool) -> void:
	is_selected = selected
	if selected:
		_apply_panel_style(Color(0.15, 0.45, 0.15, 0.95), Color(0.35, 1.0, 0.35, 1.0), 3, 4)
	else:
		_apply_panel_style(Color(0.15, 0.18, 0.24, 0.9), Color(0.4, 0.5, 0.7, 0.8), 1, 4)

func _apply_panel_style(bg: Color, border: Color, bw: int, cr: int) -> void:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = bg
	style_box.border_color = border
	style_box.set_border_width_all(bw)
	style_box.set_corner_radius_all(cr)
	add_theme_stylebox_override("panel", style_box)

# ─── Main update ──────────────────────────────────────────────────────────────

func set_slot(item_name: String, amount: int, icon_path: String, durability: int = -1, max_durability: int = -1) -> void:
	if item_name != "" and amount > 0:
		amount_label.text = str(amount) if amount > 1 else ""
		amount_label.visible = true

		# --- Icon ---
		var icon_data = ITEM_ICONS.get(item_name, "")

		if typeof(icon_data) == TYPE_STRING:
			if icon_data != "" and (ResourceLoader.exists(icon_data) or FileAccess.file_exists(icon_data)):
				icon_rect.texture = load(icon_data)
				icon_rect.visible = true
			else:
				icon_rect.visible = false

		elif typeof(icon_data) == TYPE_DICTIONARY:
			var path_to_load: String = icon_data.get("texture", "")
			var region: Rect2 = icon_data.get("region", Rect2())
			if path_to_load != "" and (ResourceLoader.exists(path_to_load) or FileAccess.file_exists(path_to_load)):
				var atlas = AtlasTexture.new()
				atlas.atlas = load(path_to_load)
				atlas.region = region
				icon_rect.texture = atlas
				icon_rect.visible = true
			else:
				icon_rect.visible = false
		else:
			icon_rect.visible = false

		# --- Durability bar ---
		if durability > 0 and max_durability > 0:
			durability_bar.max_value = max_durability
			durability_bar.value = durability
			durability_bar.visible = true
			var pct := float(durability) / float(max_durability)
			if pct > 0.6:
				durability_bar.modulate = Color(0.2, 0.9, 0.2)   # green
			elif pct > 0.3:
				durability_bar.modulate = Color(1.0, 0.75, 0.0)  # yellow
			else:
				durability_bar.modulate = Color(1.0, 0.2, 0.1)   # red
		else:
			durability_bar.visible = false
	else:
		amount_label.visible = false
		icon_rect.visible = false
		durability_bar.visible = false
