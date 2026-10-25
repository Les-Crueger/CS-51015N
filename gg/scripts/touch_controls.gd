extends CanvasLayer

# On-screen touch/virtual controls for Web and Mobile platforms (Week 8 platform tweak)

@onready var container: Control = $Control

func _ready() -> void:
	layer = 25
	# Strictly separate: only show on actual mobile OS (Android, iOS) or physical touchscreens
	var is_mobile_os: bool = OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("mobile")
	var is_touchscreen: bool = DisplayServer.is_touchscreen_available()
	
	# Hidden on PC desktop by default; visible only on mobile devices
	container.visible = is_mobile_os or is_touchscreen

	_setup_button($Control/DPad/Up, "move_up")
	_setup_button($Control/DPad/Down, "move_down")
	_setup_button($Control/DPad/Left, "move_left")
	_setup_button($Control/DPad/Right, "move_right")
	_setup_button($Control/Actions/Interact, "interact")
	_setup_button($Control/Actions/RunBtn, "move_run")
	
	var bag_btn = get_node_or_null("Control/Actions/InventoryBtn")
	if bag_btn:
		bag_btn.pressed.connect(_on_inventory_pressed)

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

func _on_inventory_pressed() -> void:
	# Simulate pressing KEY_I to toggle inventory on mobile devices
	var ev = InputEventKey.new()
	ev.keycode = KEY_I
	ev.pressed = true
	Input.parse_input_event(ev)

func _unhandled_input(event: InputEvent) -> void:
	# Quick toggle for testing on desktop anytime (F2)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F2:
			container.visible = not container.visible
