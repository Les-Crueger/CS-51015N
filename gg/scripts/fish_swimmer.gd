extends Node2D

# ─────────────────────────────────────────────
#  Place this scene anywhere in the editor.
#  Every property below is editable per-fish
#  directly in the Inspector — no code needed.
# ─────────────────────────────────────────────

@export_group("Swim Motion")
@export_enum("Horizontal", "Vertical", "Circular") var swim_axis: int = 0
@export var swim_distance: float = 20.0
@export var swim_speed: float = 1.5
## Start time offset (seconds). Change per fish so they don't all move in sync.
@export var time_offset: float = 0.0

@export_group("Appearance")
@export var fish_scale: float = 0.8
@export var fish_tint: Color = Color(0.6, 0.8, 1.0, 0.85)

var _origin: Vector2
var _t: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_origin = position
	_t = time_offset
	if sprite:
		sprite.scale = Vector2.ONE * fish_scale
		sprite.modulate = fish_tint

func _process(delta: float) -> void:
	_t += delta * swim_speed
	match swim_axis:
		0: # Horizontal
			position.x = _origin.x + sin(_t) * swim_distance
			position.y = _origin.y
			if sprite:
				sprite.flip_h = sin(_t) < 0
		1: # Vertical
			position.x = _origin.x
			position.y = _origin.y + sin(_t) * swim_distance
			if sprite:
				sprite.flip_h = false
		2: # Circular
			position.x = _origin.x + sin(_t) * swim_distance
			position.y = _origin.y + cos(_t) * swim_distance * 0.4
			if sprite:
				sprite.flip_h = sin(_t) < 0

