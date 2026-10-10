extends CharacterBody2D

# --- FSM STATES ---
enum State { PATROL, CHASE }
var current_state: State = State.PATROL

# --- SETTINGS ---
@export var patrol_speed: float = 30.0
@export var chase_speed: float = 60.0
@export var patrol_distance: float = 80.0

# --- INTERNAL VARIABLES ---
var start_pos: Vector2
var patrol_dir: Vector2 = Vector2.RIGHT
var target_player: CharacterBody2D = null

# --- NODE REFERENCES ---
@onready var sprite = $Sprite2D
@onready var detect_area = $DetectArea

# --- ANIMATION SETUP ---
const FRAME_WIDTH := 32
const FRAME_HEIGHT := 32
var tex_idle = preload("res://assets/Pixel Crawler - Free Pack/Entities/Npc's/Knight/Idle-Sheet.png")
var tex_run = preload("res://assets/Pixel Crawler - Free Pack/Entities/Npc's/Knight/Run-Sheet.png")
var current_frame: int = 0
var anim_timer: float = 0.0
var max_frames: int = 4

func _ready() -> void:
	start_pos = global_position
	# Wire up detection
	detect_area.body_entered.connect(_on_player_detected)
	detect_area.body_exited.connect(_on_player_lost)

func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			_process_patrol(delta)
		State.CHASE:
			_process_chase(delta)
	
	move_and_slide()
	_process_animation(delta)

# Patrol until the player is seen
func _process_patrol(_delta: float) -> void:
	velocity = patrol_dir * patrol_speed
	
	if global_position.distance_to(start_pos) > patrol_distance:
		patrol_dir = -patrol_dir
		
	_flip_sprite(velocity.x)

# Chase the player when they are in range
func _process_chase(_delta: float) -> void:
	if target_player:
		var direction = (target_player.global_position - global_position).normalized()
		velocity = direction * chase_speed
		_flip_sprite(velocity.x)
	else:
		current_state = State.PATROL

func _on_player_detected(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		target_player = body
		current_state = State.CHASE

func _on_player_lost(body: Node2D) -> void:
	if body == target_player:
		target_player = null
		current_state = State.PATROL
		start_pos = global_position # New patrol center where they lost the player

func _process_animation(delta: float) -> void:
	if velocity.length() > 5:
		if sprite.texture != tex_run:
			sprite.texture = tex_run
			current_frame = 0
		max_frames = 6
	else:
		if sprite.texture != tex_idle:
			sprite.texture = tex_idle
			current_frame = 0
		max_frames = 4
		
	anim_timer += delta
	if anim_timer >= 0.15:
		anim_timer = 0.0
		current_frame = (current_frame + 1) % max_frames
		sprite.region_enabled = true
		sprite.region_rect = Rect2(current_frame * FRAME_WIDTH, 0, FRAME_WIDTH, FRAME_HEIGHT)

func _flip_sprite(vx: float) -> void:
	if vx > 0.1:
		sprite.flip_h = false
	elif vx < -0.1:
		sprite.flip_h = true
