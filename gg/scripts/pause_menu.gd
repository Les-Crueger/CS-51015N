extends CanvasLayer

@onready var control_node: Control = $Control
@onready var sfx_slider: HSlider = $Control/PanelContainer/MarginContainer/VBoxContainer/SFXContainer/SFXSlider
@onready var bgm_slider: HSlider = $Control/PanelContainer/MarginContainer/VBoxContainer/BGMContainer/BGMSlider
@onready var resume_btn: Button = $Control/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var main_menu_btn: Button = $Control/PanelContainer/MarginContainer/VBoxContainer/MainMenuButton
@onready var quit_btn: Button = $Control/PanelContainer/MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	control_node.visible = false
	
	if sfx_slider:
		sfx_slider.value = GameState.sfx_volume
		sfx_slider.value_changed.connect(_on_sfx_changed)

	if bgm_slider:
		bgm_slider.value = GameState.bgm_volume
		bgm_slider.value_changed.connect(_on_bgm_changed)

	if resume_btn:
		resume_btn.pressed.connect(_on_resume_pressed)

	if main_menu_btn:
		main_menu_btn.pressed.connect(_on_main_menu_pressed)

	if quit_btn:
		quit_btn.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			toggle_pause()

func toggle_pause() -> void:
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	control_node.visible = is_paused
	
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_click"):
		am.play_click()

func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

func _on_bgm_changed(value: float) -> void:
	BackgroundMusic.set_volume(value)

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	SceneTransition.change_scene_with_loading(get_tree(), "res://scenes/mainMenu.tscn", Vector2.ZERO, false)

func _on_quit_pressed() -> void:
	get_tree().quit()
