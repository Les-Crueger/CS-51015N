extends StaticBody2D

@export var text: String = "You warmed your hands by the bonfire!"
func interact() -> void:
	print("Interacted with sign: " + text)
	
	# Juice: squash and stretch when interacted
	var tween = create_tween()
	scale = Vector2.ONE
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
