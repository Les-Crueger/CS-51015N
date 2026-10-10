## AudioManager — autoload singleton
## Handles all SFX playback with independent volume control.
## BGM is handled separately by the BackgroundMusic autoload.
extends Node

# ── SFX Volume ──────────────────────────────────────────────────────────────
func set_sfx_volume(val: float) -> void:
	GameState.sfx_volume = clamp(val, 0.0, 1.0)
	# Update the SFX audio bus volume so all SFX players are affected at once
	var bus_idx := AudioServer.get_bus_index("SFX")
	if bus_idx >= 0:
		if GameState.sfx_volume <= 0.0:
			AudioServer.set_bus_volume_db(bus_idx, -80.0)
		else:
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(GameState.sfx_volume))

func get_sfx_volume() -> float:
	return GameState.sfx_volume

# ── Internal helper ─────────────────────────────────────────────────────────
func _play(path: String, pitch: float = 1.0) -> void:
	if path == "" or not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if not stream:
		return
	var p := AudioStreamPlayer.new()
	p.stream       = stream
	p.bus          = "SFX"
	p.pitch_scale  = pitch
	# Per-player volume is driven by bus; no per-player db override needed.
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

# ── Public SFX methods ───────────────────────────────────────────────────────
## Played when the player catches a fish.
func play_fish() -> void:
	_play("res://SFX/sfx/catch.wav")

## Played when an item enters the inventory.
func play_pickup() -> void:
	_play("res://SFX/sfx/item_pickup.wav")

## Played when mining a rock (randomised pitch for variety).
func play_mine() -> void:
	var hit := "res://SFX/sfx/hit_0%d.wav" % randi_range(0, 1)
	_play(hit, randf_range(0.9, 1.1))

## Played when the player walks through a portal / zone transition.
func play_portal() -> void:
	_play("res://SFX/sfx/dungeon_discovery.wav")

## Played when an interaction is locked (missing key / item).
func play_locked() -> void:
	_play("res://SFX/sfx/locked_door.wav")

## Played when a locked area is unlocked / key is obtained.
func play_unlock() -> void:
	_play("res://SFX/sfx/unlock_door.wav")

## Played when an NPC or sign starts talking.
func play_interact() -> void:
	_play("res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/audio/se036.ogg")

## Played for UI button clicks.
func play_click() -> void:
	_play("res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/audio/se008.ogg")

## Played on quest completion.
func play_quest() -> void:
	_play("res://assets/DB Complete Inventory & UI/DB Complete UI Pack 1.0/audio/se019.ogg")
