extends AnimatedSprite2D

var speed: float = 200.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var current_pos: Vector2 = position
	
	current_pos.x += speed * delta
	
	position = current_pos
	pass
