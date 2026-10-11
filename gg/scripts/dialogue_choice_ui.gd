extends CanvasLayer

signal choice_selected(index: int)

@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/Title
@onready var buttons_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/Buttons

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_choices(dialogue_text: String, options: Array) -> void:
	title_label.text = dialogue_text
	
	for child in buttons_container.get_children():
		child.queue_free()
		
	for i in range(options.size()):
		var btn = Button.new()
		btn.text = options[i]
		btn.add_theme_font_size_override("font_size", 10)
		btn.pressed.connect(func(): _on_button_pressed(i))
		buttons_container.add_child(btn)

func _on_button_pressed(index: int) -> void:
	choice_selected.emit(index)
