extends StaticBody2D

@export var required_fish_count: int = 5
@export var npc_name: String = "Fisherman Fred"

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var interact_area: Area2D = $InteractArea

const FRAME_SIZE := 48

# Peasant_A Idle Texture (4 frames)
var tex_peasant = preload("res://assets/Pixel Crawler - Free Pack/Entities/Npc's/Citizen_F/Peasant_A/Idle/Idle-Sheet.png")
var current_frame: int = 0

func _ready() -> void:
	if label:
		label.visible = false
	if sprite:
		sprite.texture = tex_peasant
		sprite.region_enabled = true
		_apply_frame()

func _process(_delta: float) -> void:
	pass  # Animation temporarily disabled

func _apply_frame() -> void:
	if sprite:
		sprite.region_rect = Rect2(current_frame * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)

func interact() -> void:
	# Find player node
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		print("No player found!")
		return

	# Face the player (flip sprite horizontally if player is to the left)
	var diff = player.global_position - global_position
	if abs(diff.x) > 5.0:
		sprite.flip_h = (diff.x < 0)

	var current_fish = 0
	if "inventory" in player and player.inventory != null:
		current_fish = player.inventory.get_item_count("Fish")

	# Juice: NPC jumps slightly when spoken to
	var tween = create_tween()
	tween.tween_property(sprite, "position:y", -5.0, 0.1)
	tween.tween_property(sprite, "position:y", 0.0, 0.1)

	if "inventory" in player and player.inventory != null:
		if player.inventory.has_item("Level 2 Key"):
			_show_dialogue("Fisherman: 'Thanks again for the 5 fish! Good luck in Level 2!'")
		elif current_fish >= required_fish_count:
			# Trade 5 Fish for Level 2 Key
			player.inventory.remove_item("Fish", required_fish_count)
			player.inventory.add_item("Level 2 Key", 1, "res://icon.svg")
			_show_dialogue("Fisherman: 'Amazing! Here is the Key to the Cave!'")
			print("QUEST COMPLETE: Traded 5 Fish for Level 2 Key!")
		else:
			_show_dialogue("Fisherman: 'Bring me 5 Fish for the Cave Key! (%d/%d)'" % [current_fish, required_fish_count])

func _show_dialogue(text: String) -> void:
	print(text)
	if label:
		label.text = text
		label.visible = true
		
		# Auto-hide dialogue after 4 seconds
		var timer = get_tree().create_timer(4.0)
		timer.timeout.connect(func(): if label: label.visible = false)
