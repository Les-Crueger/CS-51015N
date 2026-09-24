extends Area2D

@export var target_scene: String = "res://scenes/second_map.tscn"
@export var required_key_name: String = "has_level2_key"
@export var locked_message: String = "Sell 5 fish to the fisherman to get the key"

@export_group("Target Spawn Position")
@export var use_custom_spawn: bool = false
@export var target_spawn_pos: Vector2 = Vector2.ZERO

@onready var label: Label = get_node_or_null("Label")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if label:
		label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if not (body.name == "Player" or body is CharacterBody2D):
		return

	# No key required — free passage (e.g. back-transition)
	if required_key_name == "":
		_perform_transition()
		return

	# Key required — check player property
	if body.get(required_key_name) == true:
		_perform_transition()
	else:
		if label:
			label.text = locked_message
			label.visible = true

func _perform_transition() -> void:
	if label:
		label.visible = false
	if use_custom_spawn:
		GameState.target_spawn_pos = target_spawn_pos
		GameState.use_custom_spawn = true
	get_tree().change_scene_to_file(target_scene)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		if label:
			label.visible = false
