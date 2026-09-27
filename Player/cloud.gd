extends AnimatableBody2D

## How quickly a wind kick decays. Higher = the cloud stops drifting sooner.
@export var wind_damp := 1.5

var _wind_velocity := Vector2.ZERO
var _weather_velocity := 0.0

const WATER_LEVEL_MAX = 3.0
var water_level = 0.25
var _material: ShaderMaterial
var _old_emitting_state : bool = false

@onready var _rain: GPUParticles2D = $GPUParticles2D

@export var tint_strength := 1.0:
	set(value):
		tint_strength = value
		if _material:
			_material.set_shader_parameter("transition", tint_strength)

func raining() -> bool:
	return _rain.emitting

func _ready():
	_material = $Sprite2D.material
	_material.set_shader_parameter("transition", tint_strength)
	add_to_group("cloud")


func _physics_process(delta: float) -> void:
	_wind_velocity /= 1.0 + wind_damp * delta
	# Both contributions are folded into a single write here, rather than each
	# caller poking global_position directly - two scripts each doing their own
	# read-modify-write of global_position in the same tick can race and clobber
	# each other's change (this is what silently ate wind's x movement before).
	# print("global_position: ", str(global_position), ", wind_velocity: ", str(_weather_velocity))
	if global_position.y < Global.MARGIN_TOP and _weather_velocity < 0:
		_weather_velocity = 0.0
	if global_position.y > Global.MARGIN_BOTTOM and _weather_velocity > 0:
		_weather_velocity = 0.0
	if global_position.x > Global.MARGIN_RIGHT and _wind_velocity.x > 0:
		_wind_velocity.x = 0.0
	if global_position.x < Global.MARGIN_LEFT and _wind_velocity.x < 0:
		_wind_velocity.x = 0.0
	# Godot's collision recovery only resolves millimeter-scale overlaps, not
	# being fully embedded in the hill - so if we're already stuck, drop
	# collision detection entirely until wind/weather carries the cloud back
	# out, instead of trying to physically resolve a deep overlap.
	collision_mask = 0 if move_and_collide(Vector2.ZERO, true, 0.08, true) else 1

	var motion := (_wind_velocity + Vector2(0.0, _weather_velocity)) * delta
	var collision := move_and_collide(motion)
	if collision:
		var normal := collision.get_normal()
		# Only cancel velocity that's still driving into the surface - velocity
		# already pointing away from it (e.g. escaping after getting stuck)
		# must be left alone, or it gets zeroed again every frame before the
		# cloud can actually separate from the collider.
		if _wind_velocity.x * normal.x < 0.0:
			_wind_velocity.x = 0.0
		if _weather_velocity * normal.y < 0.0:
			_weather_velocity = 0.0
	#print("global_position: ", global_position)
	
	if _rain.emitting:
		water_level -= 0.003
	
	tint_strength = clamp(water_level / WATER_LEVEL_MAX, 0.0, 1.0)

## direction is -1 (left) or 1 (right). Adds an instant kick that decays over time.
func apply_wind(direction: float, force: float) -> void:
	_wind_velocity.x += direction * force
	$AudioStreamPlayerMovement.play()


## vertical_direction is -1 (up, warming) or 1 (down, cooling). Call every physics
## frame while the weather is warming/cooling; the cloud moves at exactly this
## speed regardless of what's resting on it.
func apply_weather(vertical_direction: float, speed: float) -> void:
	_weather_velocity = vertical_direction * speed
	_old_emitting_state = _rain.emitting
	_rain.emitting = vertical_direction < 0.0 and water_level > 0.0
	if _rain.emitting != _old_emitting_state:
		if _rain.emitting:
			for audio_stream_player in [
				$AudioStreamPlayer2D,
				$AudioStreamPlayer2D2
				]:
					Global.fade_in_or_out(audio_stream_player, 0.5)
		else:
			for audio_stream_player in [
				$AudioStreamPlayer2D,
				$AudioStreamPlayer2D2
				]:
					Global.fade_in_or_out(audio_stream_player, 0.5, 0.0, -80.0)

func fill_water():
	water_level += randf()
	
	if water_level > WATER_LEVEL_MAX:
		water_level = WATER_LEVEL_MAX
	
	print("water_level: ", water_level)
