extends Node

signal field_fully_watered(offset: int)
signal field_lost(offset: int)

signal weather_influenced(duration: float)

signal game_over()

var fields_saved = 0
var fields_lost = 0

func reset():
	fields_saved = 0
	fields_lost = 0

const MARGIN_LEFT = 250.0
const MARGIN_RIGHT = 50000.0
const MARGIN_TOP = 500.0
const MARGIN_BOTTOM = 2500.0

const CLOUD_AREA_LEFT = 250.0
const CLOUD_AREA_RIGHT = 2500.0
const CLOUD_AREA_TOP = 250.0
const CLOUD_AREA_BOTTOM = 1000.0
const CLOUD_COUNT_PER_ROW = 5
const CLOUD_ROWS = 2

const TREE_COUNT = 5

const VIEW_WIDTH = 5760
const VIEW_HEIGHT = 3240

const FIELDS_LOST_MAX = 1

func fade_in_or_out(audio_stream_player: AudioStreamPlayer2D, duration: float = 1.0, start_db: float = -80.0, target_db: float = 0.0) -> void:
	# Optional: Start muted or quiet before playing
	audio_stream_player.volume_db = start_db
	audio_stream_player.play()
	
	# Create a tween for smooth transition
	var tween = create_tween()
	tween.tween_property(audio_stream_player, "volume_db", target_db, duration)
