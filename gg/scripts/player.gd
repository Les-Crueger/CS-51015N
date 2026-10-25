extends CharacterBody2D

# ─────────────────────────────────────────────
#  Movement stats
# ─────────────────────────────────────────────
@export var speed: float = 80.0
@export var run_multiplier: float = 1.7
@export var acceleration: float = 800.0
@export var friction: float = 900.0

# ─────────────────────────────────────────────
#  Node refs
# ─────────────────────────────────────────────
@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: Area2D = $Interact
@onready var interact_prompt: Label = $InteractPrompt
@onready var camera: Camera2D = $Camera2D

# --- JUICE / FEEL ---
var shake_intensity: float = 0.0

func add_screen_shake(amount: float) -> void:
	shake_intensity = max(shake_intensity, amount)

func hit_stop(duration_ms: int = 40) -> void:
	OS.delay_msec(duration_ms)

# Called by guard_knight when the player is knocked out
func play_knockout() -> void:
	set_physics_process(false)
	# Screen shake
	add_screen_shake(8.0)
	# Play the death animation for the current facing direction
	play_anim("death_" + facing_direction, true)
	# Hold on the last frame — don't loop, don't return to idle
	_one_shot_queue = ""  # prevent auto-returning to idle

# ─────────────────────────────────────────────
#  Inventory & Quest System
# ─────────────────────────────────────────────
var inventory: Inventory = null
var inventory_ui_scene = preload("res://scenes/inventory_ui.tscn")
var inventory_ui = null

var admin_key_override: bool = false
var is_fishing: bool = false

var is_auto_walking: bool = false
var _auto_walk_dir: Vector2 = Vector2.ZERO
var _auto_walk_target_pos: Vector2 = Vector2.ZERO

# Helper property for level transition compatibility
var has_level2_key: bool:
	get:
		return admin_key_override or (inventory.has_item("Level 2 Key") if inventory else false)

var has_level3_key: bool:
	get:
		return admin_key_override or GameState.lit_bonfires_count >= 2 or (inventory.has_item("Level 3 Key") if inventory else false)

var has_fishing_rod: bool:
	get:
		return inventory.has_item("Fishing Rod") if inventory else true


# ─────────────────────────────────────────────
#  Animation data (4-Directional)
# ─────────────────────────────────────────────
const FRAME_SIZE := 64   # every Body_A sheet uses 64 × 64 px frames

const ANIMS := {
	"idle_side":    { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Idle_Base/Idle_Side-Sheet.png",    "frames": 4, "fps": 6,  "loop": true  },
	"idle_down":    { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Idle_Base/Idle_Down-Sheet.png",    "frames": 4, "fps": 6,  "loop": true  },
	"idle_up":      { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Idle_Base/Idle_Up-Sheet.png",      "frames": 4, "fps": 6,  "loop": true  },

	"walk_side":    { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Walk_Base/Walk_Side-Sheet.png",    "frames": 6, "fps": 8,  "loop": true  },
	"walk_down":    { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Walk_Base/Walk_Down-Sheet.png",    "frames": 6, "fps": 8,  "loop": true  },
	"walk_up":      { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Walk_Base/Walk_Up-Sheet.png",      "frames": 6, "fps": 8,  "loop": true  },

	"run_side":     { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Run_Base/Run_Side-Sheet.png",     "frames": 6, "fps": 12, "loop": true  },
	"run_down":     { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Run_Base/Run_Down-Sheet.png",     "frames": 6, "fps": 12, "loop": true  },
	"run_up":       { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Run_Base/Run_Up-Sheet.png",       "frames": 6, "fps": 12, "loop": true  },

	"fish_side":    { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Fishing_Base/Fishing_Side-Sheet.png", "frames": 8, "fps": 6, "loop": false },
	"fish_down":    { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Fishing_Base/Fishing_Down-Sheet.png", "frames": 8, "fps": 6, "loop": false },
	"fish_up":      { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Fishing_Base/Fishing_Up-Sheet.png",   "frames": 8, "fps": 6, "loop": false },


	"collect_side": { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Collect_Base/Collect_Side-Sheet.png", "frames": 8, "fps": 8, "loop": false },
	"collect_down": { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Collect_Base/Collect_Down-Sheet.png", "frames": 8, "fps": 8, "loop": false },
	"collect_up":   { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Collect_Base/Collect_Up-Sheet.png",   "frames": 8, "fps": 8, "loop": false },

	"hit_side":     { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Hit_Base/Hit_Side-Sheet.png", "frames": 4, "fps": 10, "loop": false },
	"hit_down":     { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Hit_Base/Hit_Down-Sheet.png", "frames": 4, "fps": 10, "loop": false },
	"hit_up":       { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Hit_Base/Hit_Up-Sheet.png",   "frames": 4, "fps": 10, "loop": false },

	"death_side":   { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Death_Base/Death_Side-Sheet.png", "frames": 8, "fps": 8, "loop": false },
	"death_down":   { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Death_Base/Death_Down-Sheet.png", "frames": 8, "fps": 8, "loop": false },
	"death_up":     { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Death_Base/Death_Up-Sheet.png",   "frames": 8, "fps": 8, "loop": false },
}

var current_action: String = "idle"
var facing_direction: String = "down"
var current_anim: String = ""
var current_frame: int = 0
var anim_timer: float = 0.0
var _one_shot_queue: String = ""

var _tex_cache: Dictionary = {}
var tilemap: TileMapLayer = null
var footstep_timer: float = 0.0

func _ready() -> void:
	add_to_group("player")
	tilemap = get_parent().get_node_or_null("TileMapLayer") as TileMapLayer
	
	# Pre-load all textures
	for key in ANIMS:
		_tex_cache[key] = load(ANIMS[key]["path"])
	play_action("idle")

	# Initialize Inventory & UI
	inventory = Inventory.new()
	inventory.max_slots = 10
	add_child(inventory)
	
	# Add starter Fishing Rod only if brand new game
	if not GameState.is_inventory_saved:
		inventory.add_item("Fishing Rod", 1)

	inventory_ui = inventory_ui_scene.instantiate()
	add_child(inventory_ui)
	inventory_ui.setup(inventory)

	# Instantiate Pause Menu UI
	var pause_menu_scene = preload("res://scenes/pause_menu.tscn")
	var pause_menu = pause_menu_scene.instantiate()
	add_child(pause_menu)

	# Apply customized avatar skin tint & instantiate Avatar HUD
	if GameState.avatar_created:
		var skin_colors := [
			Color(1.0, 0.90, 0.82),  # Light skin
			Color(0.65, 0.45, 0.32),  # Brown skin
			Color(0.88, 0.68, 0.55),  # Redhead / Tanned
			Color(0.55, 0.80, 0.45),  # Orc Green
			Color(0.68, 0.55, 0.82),  # Elf Purple
			Color(0.96, 0.72, 0.78),  # Pink
			Color(0.85, 0.85, 0.88),  # Pale / Skeleton
			Color(0.52, 0.58, 0.65),  # Undead
		]
		var face_i = clampi(GameState.avatar_face_index, 0, skin_colors.size() - 1)
		sprite.modulate = skin_colors[face_i]

	var avatar_hud_scene = preload("res://scenes/avatar_hud.tscn")
	var avatar_hud = avatar_hud_scene.instantiate()
	add_child(avatar_hud)

	# Virtual Touch / Web on-screen controls (Week 8 platform tweak)
	var touch_scene = preload("res://scenes/touch_controls.tscn")
	var touch_ui = touch_scene.instantiate()
	add_child(touch_ui)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_K:
			admin_key_override = not admin_key_override
			if admin_key_override:
				if inventory:
					inventory.add_item("Level 2 Key", 1, "res://icon.svg")
				print("ADMIN DEMO MODE: Granted Level 2 Key!")
			else:
				if inventory:
					inventory.remove_item("Level 2 Key", 1)
				print("ADMIN DEMO MODE: Removed Level 2 Key!")

# ════════════════════════════════════════════
#  PHYSICS
# ════════════════════════════════════════════
func _physics_process(delta: float) -> void:
	if _one_shot_queue != "":
		move_and_slide()
		return

	if is_auto_walking:
		velocity = _auto_walk_dir * speed
		_update_facing(_auto_walk_dir)
		play_action("walk")
		move_and_slide()
		if global_position.distance_to(_auto_walk_target_pos) <= 3.0:
			global_position = _auto_walk_target_pos
			is_auto_walking = false
			velocity = Vector2.ZERO
			play_action("idle")
		return

	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()

	var is_running := Input.is_key_pressed(KEY_SHIFT) and input_vector != Vector2.ZERO
	var current_speed := speed * (run_multiplier if is_running else 1.0)

	if input_vector != Vector2.ZERO:
		if is_fishing:
			is_fishing = false
		velocity = velocity.move_toward(input_vector * current_speed, acceleration * delta)
		_update_facing(input_vector)
		_footstep_juice(delta, is_running)
		play_action("run" if is_running else "walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if is_fishing:
			play_action("fish")
		else:
			sprite.scale = sprite.scale.lerp(Vector2.ONE, 10.0 * delta)
			play_action("idle")

	move_and_slide()

	if tilemap != null:
		_check_for_water()

	if Input.is_action_just_pressed("interact"):
		_try_interact()

func perform_auto_walk(dir: Vector2, dist: float) -> void:
	if dir == Vector2.ZERO or dist <= 0.0:
		return
	is_auto_walking = true
	_auto_walk_dir = dir.normalized()
	_auto_walk_target_pos = global_position + (_auto_walk_dir * dist)


# ════════════════════════════════════════════
#  ANIMATION PROCESS
# ════════════════════════════════════════════
func _process(delta: float) -> void:
	# Apply camera shake
	if shake_intensity > 0:
		if camera:
			camera.offset = Vector2(
				randf_range(-shake_intensity, shake_intensity),
				randf_range(-shake_intensity, shake_intensity)
			)
		shake_intensity = lerpf(shake_intensity, 0.0, 10.0 * delta)
		if shake_intensity < 0.5:
			shake_intensity = 0.0
			if camera:
				camera.offset = Vector2.ZERO
	
	if current_anim == "":
		return

	var data: Dictionary = ANIMS[current_anim]
	anim_timer += delta

	if anim_timer >= 1.0 / data["fps"]:
		anim_timer -= 1.0 / data["fps"]
		current_frame += 1

		if current_frame >= data["frames"]:
			if data["loop"]:
				current_frame = 0
			else:
				current_frame = data["frames"] - 1
				_on_anim_finished()

		_apply_frame()

func play_action(action: String, force: bool = false) -> void:
	current_action = action
	var full_anim_name = action + "_" + facing_direction
	play_anim(full_anim_name, force)

func play_anim(name: String, force: bool = false) -> void:
	if current_anim == name and not force:
		return
	if not ANIMS.has(name):
		push_warning("Unknown animation: " + name)
		return

	current_anim = name
	current_frame = 0
	anim_timer = 0.0
	sprite.texture = _tex_cache[name]
	_apply_frame()

func play_oneshot(action: String) -> void:
	_one_shot_queue = action
	play_action(action, true)

func _on_anim_finished() -> void:
	if _one_shot_queue != "":
		_one_shot_queue = ""
		play_action("idle", true)

func _apply_frame() -> void:
	sprite.region_enabled = true
	sprite.region_rect = Rect2(current_frame * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)

func _update_facing(dir: Vector2) -> void:
	if abs(dir.y) > abs(dir.x):
		if dir.y > 0.1:
			facing_direction = "down"
			sprite.flip_h = false
		elif dir.y < -0.1:
			facing_direction = "up"
			sprite.flip_h = false
	elif abs(dir.x) > 0.1:
		facing_direction = "side"
		sprite.flip_h = dir.x < 0

func _footstep_juice(delta: float, running: bool) -> void:
	var interval := 0.18 if running else 0.30
	footstep_timer += delta
	if footstep_timer >= interval:
		footstep_timer = 0.0
		var sq := 1.2 if running else 1.12
		var sq_y := 0.80 if running else 0.88
		var tween := create_tween()
		tween.tween_property(sprite, "scale", Vector2(sq, sq_y), 0.07)
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.10)

# ════════════════════════════════════════════
#  WATER / INTERACTION DETECTION & FISHING
# ════════════════════════════════════════════
func _check_for_water() -> void:
	var map_pos := tilemap.local_to_map(tilemap.to_local(global_position))
	var near_water := false

	for offset in [Vector2i(0,0), Vector2i(1,0), Vector2i(-1,0),
				   Vector2i(0,1), Vector2i(0,-1), Vector2i(1,1),
				   Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1)]:
		if tilemap.get_cell_source_id(map_pos + offset) == 2:
			near_water = true
			break

	if near_water:
		interact_prompt.visible = true
		if is_fishing:
			interact_prompt.text = "Press E to Stop Fishing"
		else:
			interact_prompt.text = "Press E to Fish" if has_fishing_rod else "Need fishing rod"
	else:
		if is_fishing:
			is_fishing = false
		interact_prompt.visible = false

func _try_interact() -> void:
	# ── Generic interactables FIRST (NPCs, signs, chests…) ──
	# Checked before water so NPCs near the pond are always reachable.
	var bodies := interact_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("interact"):
			var res = body.call("interact")
			if res != false:
				play_oneshot("collect")
			return

	var areas := interact_area.get_overlapping_areas()
	for area in areas:
		if area.has_method("interact"):
			var res = area.call("interact")
			if res != false:
				play_oneshot("collect")
			return
		elif area.get_parent() and area.get_parent().has_method("interact"):
			var res = area.get_parent().call("interact")
			if res != false:
				play_oneshot("collect")
			return

	# ── Water / fishing fallback ──
	if interact_prompt.visible:
		if has_fishing_rod:
			if is_fishing:
				is_fishing = false
				print("Stopped fishing.")
				play_action("idle", true)
				interact_prompt.text = "Press E to Fish"
			else:
				is_fishing = true
				print("Started fishing... Caught a Fish!")
				play_action("fish", true)
				inventory.add_item("Fish", 1)
				interact_prompt.text = "Press E to Stop Fishing"
				# Drain rod durability on each catch
				var rod_name = "Iron Fishing Rod" if inventory.has_item("Iron Fishing Rod") else "Fishing Rod"
				inventory.use_tool(rod_name)
				# Highlight active rod in inventory UI
				if inventory_ui and inventory_ui.has_method("set_active_item"):
					inventory_ui.set_active_item(rod_name)
				var am = get_node_or_null("/root/AudioManager")
				if am and am.has_method("play_fish"):
					am.play_fish()
				var tween := create_tween()
				tween.tween_property(sprite, "position:y", -6.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(sprite, "position:y", 0.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		else:
			print("You need a fishing rod!")
		return

	print("Nothing to interact with here.")
