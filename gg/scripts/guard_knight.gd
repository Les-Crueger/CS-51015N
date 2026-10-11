extends CharacterBody2D

enum State { IDLE, INTERCEPT, RETURN }
var current_state: State = State.IDLE

var start_pos: Vector2
var target_player: CharacterBody2D = null

@onready var sprite = $Sprite2D
@onready var detect_area = $DetectArea

@export var guard_speed: float = 70.0
@export var intercept_distance: float = 30.0

var dialogue_ui_scene = preload("res://scenes/dialogue_choice_ui.tscn")
var ui_instance = null

const FRAME_WIDTH := 32
const FRAME_HEIGHT := 32
var tex_idle = preload("res://assets/Pixel Crawler - Free Pack/Entities/Npc's/Knight/Idle/Idle-Sheet.png")
var tex_run = preload("res://assets/Pixel Crawler - Free Pack/Entities/Npc's/Knight/Run/Run-Sheet.png")
var current_frame: int = 0
var anim_timer: float = 0.0
var max_frames: int = 4

var has_bribed: bool = false
var reengage_cooldown: float = 0.0
var interacting: bool = false

func _ready() -> void:
	start_pos = global_position
	if detect_area:
		for child in detect_area.get_children():
			if child is CollisionShape2D and child.shape is CircleShape2D:
				child.shape.radius = 120.0
		detect_area.body_entered.connect(_on_player_detected)

func _physics_process(delta: float) -> void:
	if reengage_cooldown > 0.0:
		reengage_cooldown -= delta

	if interacting:
		_process_animation(delta)
		return

	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			# Continuously check if player is in detection radius even after previous encounters
			_check_player_in_range()
		State.INTERCEPT:
			if target_player:
				var dist = global_position.distance_to(target_player.global_position)
				if dist > intercept_distance:
					var direction = (target_player.global_position - global_position).normalized()
					velocity = direction * guard_speed
					_flip_sprite(velocity.x)
				else:
					velocity = Vector2.ZERO
					_flip_sprite(target_player.global_position.x - global_position.x)
					_start_dialogue()
			else:
				current_state = State.RETURN
		State.RETURN:
			var dist = global_position.distance_to(start_pos)
			if dist > 2.0:
				var direction = (start_pos - global_position).normalized()
				velocity = direction * guard_speed
				_flip_sprite(velocity.x)
			else:
				velocity = Vector2.ZERO
				global_position = start_pos
				current_state = State.IDLE
				_flip_sprite(-1.0) # face left naturally
				# If player is still in the zone, immediately re-approach after a short breather
				_check_player_in_range()

	move_and_slide()
	_process_animation(delta)

func _check_player_in_range() -> void:
	if has_bribed or interacting or reengage_cooldown > 0.0:
		return
	if detect_area:
		for body in detect_area.get_overlapping_bodies():
			if body.name == "Player" or body.is_in_group("player"):
				target_player = body
				current_state = State.INTERCEPT
				break

func _on_player_detected(body: Node2D) -> void:
	if has_bribed or interacting or reengage_cooldown > 0.0: return
	if body.name == "Player" or body.is_in_group("player"):
		target_player = body
		current_state = State.INTERCEPT

func _start_dialogue() -> void:
	if ui_instance != null: return
	
	interacting = true
	if target_player and target_player.has_method("set_physics_process"):
		target_player.set_physics_process(false)
		target_player.play_action("idle")
		
	ui_instance = dialogue_ui_scene.instantiate()
	get_tree().root.add_child(ui_instance)
	
	ui_instance.choice_selected.connect(_on_choice_made)
	ui_instance.show_choices(
		"Knight: Halt! I'm here to guard the village's entrance. State your business.",
		[
			"Bribe the guard (Needs Gold Ingot)",
			"Ask why you can't enter",
			"Agree to leave",
			"Ignore him and push past"
		]
	)

func _on_choice_made(index: int) -> void:
	match index:
		0:
			if target_player and "inventory" in target_player:
				var inv = target_player.inventory
				if inv.has_item("Gold Ingot", 1):
					inv.remove_item("Gold Ingot", 1)
					has_bribed = true
					_finish_interaction("Knight: ...Keep it quiet. Pass.")
					return
			_knockout("Knight: Empty pockets? How dare you insult a Royal Guard!")
		1:
			ui_instance.show_choices(
				"Knight: The village is strictly quarantined by order of the King.",
				[
					"Bribe the guard (Needs Gold Ingot)",
					"Agree to leave",
					"Ignore him and push past"
				]
			)
			ui_instance.choice_selected.disconnect(_on_choice_made)
			ui_instance.choice_selected.connect(_on_followup_choice)
		2:
			_finish_interaction("Knight: A wise choice. Begone.")
		3:
			_knockout("Knight: Treason! You shall not pass!")

func _on_followup_choice(index: int) -> void:
	if index == 0: _on_choice_made(0)
	elif index == 1: _on_choice_made(2)
	elif index == 2: _on_choice_made(3)

func _finish_interaction(msg: String) -> void:
	print(msg)
	if ui_instance:
		ui_instance.queue_free()
		ui_instance = null
	
	interacting = false
	if target_player and target_player.has_method("set_physics_process"):
		target_player.set_physics_process(true)
		
	if has_bribed:
		start_pos = start_pos + Vector2(0, -60)
		current_state = State.RETURN
	else:
		if target_player:
			target_player.global_position.x -= 30
		reengage_cooldown = 1.2 # Brief delay so player can walk back, but will approach again if they stay or step forward
		current_state = State.RETURN

func _knockout(msg: String) -> void:
	print(msg)
	if ui_instance:
		ui_instance.queue_free()
		ui_instance = null

	# Play death animation + screen shake on the player
	if target_player and target_player.has_method("play_knockout"):
		target_player.play_knockout()

	if get_node_or_null("/root/AudioManager"):
		AudioManager.play_mine()

	# Wait for the death animation to play (~0.8s), then fade to black and respawn
	var scene_tree = get_tree()
	await scene_tree.create_timer(0.8).timeout

	var canvas = CanvasLayer.new()
	canvas.layer = 200
	var rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.modulate.a = 0.0
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(rect)
	scene_tree.root.add_child(canvas)

	# "Knocked out..." text
	var ko_label = Label.new()
	ko_label.text = "Knocked out..."
	ko_label.modulate.a = 0.0
	ko_label.add_theme_font_size_override("font_size", 22)
	ko_label.set_anchors_preset(Control.PRESET_CENTER)
	ko_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	canvas.add_child(ko_label)

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(ko_label, "modulate:a", 1.0, 0.5)
	tween.tween_callback(func():
		if target_player:
			target_player.global_position = Vector2(25, 28)
			if target_player.has_method("play_action"):
				target_player.play_action("idle", true)
			if target_player.has_method("set_physics_process"):
				target_player.set_physics_process(true)
		interacting = false
		current_state = State.RETURN
	)
	tween.tween_interval(0.8)
	tween.tween_property(rect, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(ko_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(canvas.queue_free)

func _process_animation(delta: float) -> void:
	var is_running = velocity.length() > 5.0
	
	if is_running:
		if sprite.texture != tex_run:
			sprite.texture = tex_run
			current_frame = 0
			anim_timer = 0.0
		max_frames = 6
	else:
		if sprite.texture != tex_idle:
			sprite.texture = tex_idle
			current_frame = 0
			anim_timer = 0.0
		max_frames = 4

	# Run animation speed (faster cadence when sprinting)
	var frame_duration = 0.10 if is_running else 0.16
	anim_timer += delta
	if anim_timer >= frame_duration:
		anim_timer = 0.0
		current_frame = (current_frame + 1) % max_frames

	sprite.region_enabled = true
	if is_running:
		# Run-Sheet is 384x64 with 6 frames of 64x64.
		# The knight's feet align at Y=64, so offset sprite Y position by -16 to align with 32x32 idle.
		sprite.region_rect = Rect2(current_frame * 64, 0, 64, 64)
		sprite.offset = Vector2(0, -16)
	else:
		# Idle-Sheet is 128x32 with 4 frames of 32x32.
		sprite.region_rect = Rect2(current_frame * 32, 0, 32, 32)
		sprite.offset = Vector2.ZERO

func _flip_sprite(vx: float) -> void:
	if vx > 0.1:
		sprite.scale.x = 1
	elif vx < -0.1:
		sprite.scale.x = -1
