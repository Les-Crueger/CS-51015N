extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var v_box = $VBoxContainer
@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var subtext_label = $VBoxContainer/Subtext

var loading_phrases: Array[String] = [
	"Adding assets...",
	"Rendering pixels...",
	"Initiating 'zen mode'...",
	"The creator is taking a break...",
	"This loading might take a while...",
	"Okay, this loading sequence is taking long...",
	"Moving avatar safely onward...",
	"Untangling the code...",
	"Polishing the rocks...",
	"Waking up the NPCs...",
	"Your character lost their clothes... oops"]

var timer_count: float = 0.0
var phrase_index: int = 0

func _ready() -> void:
	# Start fully transparent
	color_rect.color.a = 0.0
	v_box.modulate.a = 0.0
	
	# Pick a random starting phrase
	phrase_index = randi() % loading_phrases.size()
	if subtext_label:
		subtext_label.text = loading_phrases[phrase_index]

func _process(delta: float) -> void:
	# Cycle the text every 2.5 seconds
	timer_count += delta
	if timer_count > 2.5:
		timer_count = 0.0
		phrase_index = (phrase_index + 1) % loading_phrases.size()
		if subtext_label:
			subtext_label.text = loading_phrases[phrase_index]

func fade_in() -> Tween:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(color_rect, "color:a", 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(v_box, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return tween

func fade_out() -> Tween:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(color_rect, "color:a", 0.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(v_box, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	return tween
