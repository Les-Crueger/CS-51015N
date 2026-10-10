extends Area2D

@export var target_scene: String = "res://scenes/second_map.tscn"
@export var required_key_name: String = "has_level2_key"
@export var locked_message: String = "Sell 5 fish to the fisherman to get the key"

@export_group("Target Spawn Position")
@export var use_custom_spawn: bool = false
@export var target_spawn_pos: Vector2 = Vector2.ZERO
@export var spawn_walk_direction: Vector2 = Vector2.RIGHT
@export var spawn_walk_distance: float = 36.0

@onready var label: Label = get_node_or_null("Label")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if label:
		label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if GameState.is_transitioning:
		return

	if not (body.name == "Player" or body is CharacterBody2D):
		return

	# No key required — free passage (e.g. back-transition)
	if required_key_name == "":
		_perform_transition(body)
		return

	# Key required — check player property
	if body.get(required_key_name) == true:
		_perform_transition(body)
	else:
		if label:
			label.text = locked_message
			label.visible = true

func _perform_transition(body: Node2D = null) -> void:
	if label:
		label.visible = false

	var spawn_pos := target_spawn_pos
	var should_use_custom := use_custom_spawn

	# If no custom spawn given, fall back to GameState.previous_player_pos
	# so back-transition zones return the player to where they were
	if not use_custom_spawn and target_spawn_pos == Vector2.ZERO:
		if GameState.previous_player_pos != Vector2.ZERO:
			spawn_pos = GameState.previous_player_pos
			should_use_custom = true

	# Save current player position before leaving
	if body:
		GameState.previous_player_pos = body.global_position

	# Play transition SFX
	if Engine.has_singleton("AudioManager") or get_node_or_null("/root/AudioManager"):
		AudioManager.play_portal()

	SceneTransition.change_scene_with_loading(
		get_tree(),
		target_scene,
		spawn_pos,
		should_use_custom,
		spawn_walk_direction,
		spawn_walk_distance
	)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		if label:
			label.visible = false
