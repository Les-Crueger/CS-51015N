extends Sprite2D

var speed = 200

func _process(delta):
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		position.x += speed * delta
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		position.x -= speed * delta
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		position.y -= speed * delta
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		position.y += speed * delta

	# Clamp to screen bounds
	var screen_size = get_viewport_rect().size
	var half_size = texture.get_size() * scale / 2

	position.x = clamp(position.x, half_size.x, screen_size.x - half_size.x)
	position.y = clamp(position.y, half_size.y, screen_size.y - half_size.y)
