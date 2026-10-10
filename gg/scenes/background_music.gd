## BackgroundMusic — autoload singleton
## Manages per-map BGM tracks and volume independent of SFX.
## Assigned in Project > Autoloads as "BackgroundMusic".
extends Node

# ── Audio player (created at runtime so this works as an autoload script) ──
var _player: AudioStreamPlayer = null

# ── Per-scene BGM tracks ────────────────────────────────────────────────────
# Keys are the scene resource path; values are preloaded AudioStreams.
const TRACKS: Dictionary = {
	"res://scenes/firstmap.tscn":   "res://Music/music/little corner of heaven.mp3",
	"res://scenes/third_map.tscn": "res://Music/music/cave maybe.mp3",
	"res://scenes/second_map.tscn":  "res://Music/music/Mixdown(2).mp3",
}

var _current_path: String = ""

# ── Lifecycle ───────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # keep music during pause

	_player = AudioStreamPlayer.new()
	_player.name = "BGMPlayer"
	_player.bus  = "Background music"          # route to dedicated BGM bus
	add_child(_player)

	set_volume(GameState.bgm_volume)

# ── Public API ──────────────────────────────────────────────────────────────

## Call from each map's _ready() with its own scene path,
## e.g. BackgroundMusic.play_for_scene("res://scenes/firstmap.tscn")
func play_for_scene(scene_path: String) -> void:
	if scene_path == _current_path and _player.playing:
		return   # already playing the right track

	var resource_path: String = TRACKS.get(scene_path, "")
	if resource_path == "":
		# No track registered for this scene — stop music
		_player.stop()
		_current_path = ""
		return

	_current_path = scene_path

	var stream: AudioStream = load(resource_path)
	if not stream:
		push_warning("BackgroundMusic: Could not load " + resource_path)
		return

	# Enable looping on MP3/OGG streams if the property exists
	if stream.has_method("set_loop") or "loop" in stream:
		stream.loop = true

	_player.stream = stream
	_player.play()

## Stop music immediately (e.g. cutscene, game over).
func stop() -> void:
	if _player:
		_player.stop()
	_current_path = ""

## Volume: 0.0 (silent) … 1.0 (full).  Saved into GameState.
func set_volume(val: float) -> void:
	GameState.bgm_volume = clamp(val, 0.0, 1.0)
	if _player:
		if GameState.bgm_volume <= 0.0:
			_player.volume_db = -80.0
		else:
			_player.volume_db = linear_to_db(clamp(GameState.bgm_volume, 0.0001, 1.0))
