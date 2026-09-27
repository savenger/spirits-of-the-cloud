class_name WindMinigame
extends CanvasLayer

## Emitted when the player locks in a timing. direction is -1 (left), 1 (right) or 0 (missed).
signal resolved(direction: int)

## Seconds for one full left-to-right-to-left sweep of the marker.
@export var oscillation_period := 1.2
## Fraction of the track (measured from each edge) that counts as a successful hit.
@export var target_zone_fraction := 0.22
## Width of the track, in pixels.
@export var track_width := 400.0

var _time := 0.0
var _value := 0.0 # -1.0 (all the way left) .. 1.0 (all the way right)

@onready var _marker: ColorRect = $Root/Marker
@onready var _track: ColorRect = $Root/Track
@onready var _left_zone: ColorRect = $Root/LeftZone
@onready var _right_zone: ColorRect = $Root/RightZone


func _ready() -> void:
	var zone_width := track_width * target_zone_fraction

	_track.size.x = track_width
	_left_zone.size.x = zone_width
	_right_zone.size.x = zone_width
	_right_zone.position.x = track_width - zone_width

	# Randomize the starting phase so the marker isn't at the same spot (and
	# thus at a predictable timing) every time the popup opens.
	_time = randf_range(0.0, oscillation_period)
	_value = sin(_time * TAU / oscillation_period)

	_update_marker()


func _process(delta: float) -> void:
	_time += delta
	_value = sin(_time * TAU / oscillation_period)
	_update_marker()


func _update_marker() -> void:
	var half_track := track_width * 0.5
	_marker.position.x = half_track + _value * half_track - _marker.size.x * 0.5


## Locks in the current marker position, emits the result and closes the popup.
func resolve() -> float:
	var direction := 0.0

	if _value >= 1.0 - 2.0 * target_zone_fraction:
		direction = _value * _value
	elif _value <= -(1.0 - 2.0 * target_zone_fraction):
		direction = - (_value * _value)
	
	print("WIND: _value: ", _value, ", direction: ", direction)

	resolved.emit(direction)
	queue_free()
	return direction


## Closes the popup without applying any effect.
func cancel() -> void:
	queue_free()
