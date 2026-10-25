extends CanvasLayer

# On-screen touch/virtual controls for Web and Mobile platforms (Week 8 platform tweak)

@onready var container: Control = $Control

func _ready() -> void:
	layer = 25
	# Show on Web or touchscreens, or allow testing with a toggle key
	var is_web: bool = OS.has_feature("web")
	var is_touch: bool = DisplayServer.is_touchscreen_available()
	container.visible = is_web or is_touch

	_setup_button($Control/DPad/Up, "move_up")
	_setup_button($Control/DPad/Down, "move_down")
	_setup_button($Control/DPad/Left, "move_left")
	_setup_button($Control/DPad/Right, "move_right")
	_setup_button($Control/Actions/Interact, "interact")

func _setup_button(btn: Button, action_name: String) -> void:
	if not btn:
		return
	btn.button_down.connect(func():
		var ev = InputEventAction.new()
		ev.action = action_name
		ev.pressed = true
		Input.parse_input_event(ev)
	)
	btn.button_up.connect(func():
		var ev = InputEventAction.new()
		ev.action = action_name
		ev.pressed = false
		Input.parse_input_event(ev)
	)
