extends Node2D

@export var swim_distance: float = 20.0
@export var swim_speed: float = 1.5

var start_pos: Vector2
var time_passed: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	start_pos = position

func _process(delta: float) -> void:
	time_passed += delta * swim_speed
	# Gentle back-and-forth swimming motion
	position.x = start_pos.x + sin(time_passed) * swim_distance
	position.y = start_pos.y + cos(time_passed * 0.5) * (swim_distance * 0.3)
	
	if sprite:
		sprite.flip_h = cos(time_passed) < 0
