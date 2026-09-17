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

# ─────────────────────────────────────────────
#  Inventory / Equipment flags
# ─────────────────────────────────────────────
var has_fishing_rod: bool = false   # set true when player picks up rod

# ─────────────────────────────────────────────
#  Animation data
#  Each entry: { tex, frame_w, frame_h, frame_count, fps, loop }
#  frame_w / frame_h are the pixel size of ONE frame on the sheet.
# ─────────────────────────────────────────────
const FRAME_SIZE := 64   # every Body_A sheet uses 64 × 64 px frames

const ANIMS := {
	"idle":    { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Idle_Base/Idle_Side-Sheet.png",    "frames": 4, "fps": 6,  "loop": true  },
	"walk":    { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Walk_Base/Walk_Side-Sheet.png",    "frames": 6, "fps": 8,  "loop": true  },
	"run":     { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Run_Base/Run_Side-Sheet.png",     "frames": 6, "fps": 12, "loop": true  },
	"fish":    { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Fishing_Base/Fishing_Side-Sheet.png", "frames": 8, "fps": 6, "loop": true },
	"collect": { "path": "res://assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations/Collect_Base/Collect_Side-Sheet.png", "frames": 8, "fps": 8, "loop": false },
}

# ─────────────────────────────────────────────
#  Animation runtime state
# ─────────────────────────────────────────────
var current_anim: String = ""
var current_frame: int = 0
var anim_timer: float = 0.0
var _anim_done: bool = false   # true when a non-looping anim finished
var _one_shot_queue: String = ""  # play this once, then return to normal

# Cached textures
var _tex_cache: Dictionary = {}

# ─────────────────────────────────────────────
#  Tilemap ref for water detection
# ─────────────────────────────────────────────
var tilemap: TileMapLayer = null

# ─────────────────────────────────────────────
#  Juice
# ─────────────────────────────────────────────
var footstep_timer: float = 0.0

func _ready() -> void:
	tilemap = get_parent().get_node_or_null("TileMapLayer") as TileMapLayer
	# Pre-load all textures
	for key in ANIMS:
		_tex_cache[key] = load(ANIMS[key]["path"])
	play_anim("idle")

# ════════════════════════════════════════════
#  PHYSICS
# ════════════════════════════════════════════
func _physics_process(delta: float) -> void:
	# Don't interrupt one-shot animations with movement
	if _one_shot_queue != "":
		move_and_slide()
		return

	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()

	var is_running := Input.is_key_pressed(KEY_SHIFT) and input_vector != Vector2.ZERO
	var current_speed := speed * (run_multiplier if is_running else 1.0)

	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * current_speed, acceleration * delta)
		_update_facing(input_vector)
		_footstep_juice(delta, is_running)
		play_anim("run" if is_running else "walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		sprite.scale = sprite.scale.lerp(Vector2.ONE, 10.0 * delta)
		play_anim("idle")

	move_and_slide()

	if tilemap != null:
		_check_for_water()

	if Input.is_action_just_pressed("interact"):
		_try_interact()

# ════════════════════════════════════════════
#  ANIMATION PROCESS
# ════════════════════════════════════════════
func _process(delta: float) -> void:
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
				# Non-looping anim finished → hold last frame, signal done
				current_frame = data["frames"] - 1
				_on_anim_finished()

		_apply_frame()

# ─────────────────────────────────────────────
#  Play an animation by name
#    force = restart even if already playing
# ─────────────────────────────────────────────
func play_anim(name: String, force: bool = false) -> void:
	if current_anim == name and not force:
		return
	if not ANIMS.has(name):
		push_warning("Unknown animation: " + name)
		return

	current_anim = name
	current_frame = 0
	anim_timer = 0.0
	_anim_done = false
	sprite.texture = _tex_cache[name]
	_apply_frame()

# ─────────────────────────────────────────────
#  Play a one-shot (non-looping) animation,
#  then automatically return to idle/walk/run.
# ─────────────────────────────────────────────
func play_oneshot(name: String) -> void:
	_one_shot_queue = name
	play_anim(name, true)

func _on_anim_finished() -> void:
	if _one_shot_queue != "":
		_one_shot_queue = ""
		play_anim("idle", true)

# ─────────────────────────────────────────────
#  Apply the current frame index as a region
# ─────────────────────────────────────────────
func _apply_frame() -> void:
	sprite.region_enabled = true
	sprite.region_rect = Rect2(current_frame * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)

# ════════════════════════════════════════════
#  HELPERS
# ════════════════════════════════════════════
func _update_facing(dir: Vector2) -> void:
	if abs(dir.x) > 0.1:
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
#  WATER / INTERACTION DETECTION
# ════════════════════════════════════════════
func _check_for_water() -> void:
	var map_pos := tilemap.local_to_map(tilemap.to_local(global_position))
	var near_water := false

	for offset in [Vector2i(0,0), Vector2i(1,0), Vector2i(-1,0),
				   Vector2i(0,1), Vector2i(0,-1), Vector2i(1,1),
				   Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1)]:
		# source_id 2 = Water_tiles.png in map.tscn
		if tilemap.get_cell_source_id(map_pos + offset) == 2:
			near_water = true
			break

	if near_water:
		interact_prompt.visible = true
		interact_prompt.text = "Press E to Fish" if has_fishing_rod else "Need fishing rod"
	else:
		interact_prompt.visible = false

func _try_interact() -> void:
	# ── Water / fishing ──
	if interact_prompt.visible:
		if has_fishing_rod:
			print("Fishing... Splash!")
			play_oneshot("fish")
			var tween := create_tween()
			tween.tween_property(sprite, "position:y", -6.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(sprite, "position:y", 0.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		else:
			print("You need a fishing rod!")
		return

	# ── Generic interactables (signs, NPCs, chests…) ──
	var bodies := interact_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("interact"):
			play_oneshot("collect")
			body.interact()
			return

	print("Nothing to interact with here.")
