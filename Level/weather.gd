extends Node

## Automatic warm/cold weather cycle. While warming, the cloud is pushed up;
## while cooling, it's pushed down. Runs on its own, with no player input.

enum State { WARMING, COOLING }

## Seconds spent warming before switching to cooling, and vice versa.
@export var phase_duration := 6.0
## Speed the cloud rises/falls at while warming/cooling, in pixels per second.
## Kept a bit lower than the wind minigame's kick (wind_force on Player) works
## out to over its decay, so weather reads as a gentle drift rather than a shove.
@export var speed := 260.0

var _state := State.WARMING
var _phase_time := 0.0

func _ready() -> void:
	Global.weather_influenced.connect(weather_influenced)

func weather_influenced(duration: float) -> void:
	if duration == 0.0:
		return
	phase_duration = abs(duration)
	_phase_time = 0.0
	_state = State.COOLING if duration > 0.0 else State.WARMING

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player.is_physics_processing():
		return
	_phase_time += delta

	if _phase_time >= phase_duration:
		_phase_time -= phase_duration
		_state = State.COOLING if _state == State.WARMING else State.WARMING
		phase_duration = 4.0 + randf() * 5.0

	var cloud := get_tree().get_first_node_in_group("cloud")
	if cloud == null:
		return

	# Negative Y is "up" in Godot's 2D space, so warming (rising) pushes upward.
	var vertical_direction := -1.0 if _state == State.WARMING else 1.0
	cloud.apply_weather(vertical_direction, speed)
