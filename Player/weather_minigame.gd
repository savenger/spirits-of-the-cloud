class_name WeatherMinigame
extends CanvasLayer

## Seconds for one full left-to-right-to-left sweep of the marker.
@export var oscillation_period := 1.2
## Fraction of the track (measured from each edge) that counts as a successful hit.
@export var target_zone_fraction := 0.22
## Width of the track, in pixels.
@export var track_height := 400.0

var _time := 0.0
var _value := 0.0 # -1.0 (all the way left) .. 1.0 (all the way right)

@onready var _marker: ColorRect = $Root/Marker
@onready var _track: ColorRect = $Root/Track
@onready var _left_zone: ColorRect = $Root/LeftZone
@onready var _right_zone: ColorRect = $Root/RightZone


func _ready() -> void:
	var zone_height := track_height * target_zone_fraction

	_track.size.y = track_height
	_left_zone.size.y = zone_height
	_right_zone.size.y = zone_height
	_right_zone.position.y = track_height - zone_height

	# Randomize the starting phase so the marker isn't at the same spot (and
	# thus at a predictable timing) every time the popup opens.
	_time = randf_range(0.0, oscillation_period)
	_value = sin(_time * TAU / oscillation_period)

	_update_marker()
	
	Global.game_over.connect(cancel)


func _process(delta: float) -> void:
	_time += delta
	_value = sin(_time * TAU / oscillation_period)
	_update_marker()


func _update_marker() -> void:
	var half_track := track_height * 0.5
	_marker.position.y = half_track + _value * half_track - _marker.size.y * 0.5


## Locks in the current marker position, emits the result and closes the popup.
func resolve() -> float:
	var duration := 0.0

	if _value >= 1.0 - 2.0 * target_zone_fraction:
		duration = 4.0 + 5.0 * _value * _value
	elif _value <= -(1.0 - 2.0 * target_zone_fraction):
		duration = -4.0 - 5.0 * (_value * _value)
	
	print("WEATHER: _value: ", _value, ", duration: ", duration)

	Global.weather_influenced.emit(duration)
	queue_free()
	return duration


## Closes the popup without applying any effect.
func cancel() -> void:
	queue_free()
