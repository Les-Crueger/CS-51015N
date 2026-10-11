extends Node
class_name GameState

static var target_spawn_pos: Vector2 = Vector2.ZERO
static var use_custom_spawn: bool = false
static var spawn_walk_dir: Vector2 = Vector2.RIGHT
static var spawn_walk_dist: float = 36.0
static var is_transitioning: bool = false
static var previous_player_pos: Vector2 = Vector2.ZERO

# Persistent inventory state
static var saved_inventory_slots: Array = []
static var is_inventory_saved: bool = false

# Quest states
static var caveman_items_given: bool = false
static var lit_bonfires_count: int = 0

# Audio settings
static var sfx_volume: float = 0.8
static var bgm_volume: float = 0.6

# Avatar customization (tile indices into the spritesheet)
static var avatar_face_index: int = 0
static var avatar_hair_index: int = 0
static var avatar_outfit_index: int = 0
static var avatar_created: bool = false

static func save_inventory(slots: Array) -> void:
	saved_inventory_slots.clear()
	for slot in slots:
		saved_inventory_slots.append(slot.duplicate(true))
	is_inventory_saved = true
	save_to_disk()

static func load_inventory(inventory: Inventory) -> bool:
	if not is_inventory_saved:
		return false
	inventory.slots.clear()
	for slot in saved_inventory_slots:
		inventory.slots.append(slot.duplicate(true))
	inventory.inventory_updated.emit()
	return true

# --- DISK SAVE / LOAD ---
const SAVE_PATH = "user://savegame.json"

static func save_to_disk() -> void:
	var save_dict = {
		"inventory_slots": saved_inventory_slots,
		"is_inventory_saved": is_inventory_saved,
		"caveman_items_given": caveman_items_given,
		"lit_bonfires_count": lit_bonfires_count,
		"sfx_volume": sfx_volume,
		"bgm_volume": bgm_volume,
		"avatar_face_index": avatar_face_index,
		"avatar_hair_index": avatar_hair_index,
		"avatar_outfit_index": avatar_outfit_index,
		"avatar_created": avatar_created,
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict))
		file.close()

static func load_from_disk() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var data = json.data
			if typeof(data) == TYPE_DICTIONARY:
				if data.has("inventory_slots"):
					saved_inventory_slots = data["inventory_slots"]
				if data.has("is_inventory_saved"):
					is_inventory_saved = data["is_inventory_saved"]
				if data.has("caveman_items_given"):
					caveman_items_given = data["caveman_items_given"]
				if data.has("lit_bonfires_count"):
					lit_bonfires_count = data["lit_bonfires_count"]
				if data.has("sfx_volume"):
					sfx_volume = data["sfx_volume"]
				if data.has("bgm_volume"):
					bgm_volume = data["bgm_volume"]
				if data.has("avatar_face_index"):
					avatar_face_index = int(data["avatar_face_index"])
				if data.has("avatar_hair_index"):
					avatar_hair_index = int(data["avatar_hair_index"])
				if data.has("avatar_outfit_index"):
					avatar_outfit_index = int(data["avatar_outfit_index"])
				if data.has("avatar_created"):
					avatar_created = data["avatar_created"]
				return true
	return false
