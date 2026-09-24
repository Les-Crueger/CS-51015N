extends Area2D

@export var target_scene: String = "res://scenes/firstmap.tscn"
@export var required_key_name: String = "has_level2_key"

@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if label:
		label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		if body.get(required_key_name) == true:
			# Hide any label and immediately transport player to second_map
			if label:
				label.visible = false
			get_tree().change_scene_to_file(target_scene)


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		if label:
			label.visible = false
