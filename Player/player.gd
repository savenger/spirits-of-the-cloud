extends CharacterBody2D


@export var speed := 1500.0
enum SpiritType { WATER, WIND }
@export var spirit_type := SpiritType.WATER

@export_group("Jump")
## Peak height of the jump, in pixels.
@export var jump_height := 450.0
## Time from leaving the ground to reaching the peak of the jump.
@export var jump_time_to_peak := 0.35
## Falling is this many times "heavier" than rising, so the jump feels snappy instead of floaty.
@export var fall_gravity_multiplier := 1.6

@export var can_call_wind := false
@export var can_influence_weather := false

@export_group("Wind")
## Impulse applied to the cloud when the wind timing minigame is hit.
@export var wind_force := 2500.0

const WindMinigameScene := preload("res://Player/wind_minigame.tscn")
const WeatherMinigameScene := preload("res://Player/weather_minigame.tscn")

var sprite : AnimatedSprite2D

var input: PlayerInput

var jump_velocity: float
var rise_gravity: float
var fall_gravity: float

var _wind_minigame: WindMinigame
var _weather_minigame: WeatherMinigame

func _ready() -> void:
	jump_velocity = -2.0 * jump_height / jump_time_to_peak
	rise_gravity = 2.0 * jump_height / (jump_time_to_peak * jump_time_to_peak)
	fall_gravity = rise_gravity * fall_gravity_multiplier

	if spirit_type == SpiritType.WATER:
		$Sprite2D.texture = load("res://Assets/Water_Spirit.png")
		sprite = $AnimatedSprite2DWater
		$AnimatedSprite2DWater.visible = true
		$AnimatedSprite2DWind.visible = false
	else:
		$Sprite2D.texture = load("res://Assets/Wind_Spirit.png")
		sprite = $AnimatedSprite2DWind
		$AnimatedSprite2DWater.visible = false
		$AnimatedSprite2DWind.visible = true

func _physics_process(delta: float) -> void:
	if input == null:
		return

	# Same rescue Cloud uses on itself: if the cloud shoves us into a hill hard
	# enough that Godot's collision recovery can't fully depenetrate us in one
	# step, we'd otherwise stay wedged in the hill forever even after the cloud
	# moves on. Briefly stop colliding with terrain (layer 1, shared with the
	# cloud) so gravity/movement can carry us back out.
	collision_mask = 6 if move_and_collide(Vector2.ZERO, true, 0.08, true) else 7

	if not is_on_floor():
		var gravity := rise_gravity if velocity.y < 0.0 else fall_gravity
		velocity.y += gravity * delta

	var direction := input.get_move_direction()

	if direction != 0.0:
		velocity.x = direction * speed
		sprite.flip_h = direction < 0.0
		sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		sprite.play("idle")

	if input.is_jump_just_pressed() and is_on_floor():
		velocity.y = jump_velocity
		$AudioStreamPlayer2DJump.play()

	if input.is_call_wind_just_pressed() and can_call_wind and not _weather_minigame:
		if _wind_minigame:
			_resolve_wind_minigame()
		else:
			_start_wind_minigame()

	if input.is_influence_weather_just_pressed() and can_influence_weather and not _wind_minigame:
		if _weather_minigame:
			_resolve_weather_minigame()
		else:
			_start_weather_minigame()
	
	if input.is_cancel_just_pressed():
		if _weather_minigame:
			_weather_minigame.cancel()
			_weather_minigame = null
		if _wind_minigame:
			_wind_minigame.cancel()
			_wind_minigame = null

	move_and_slide()
	
	var cam = get_tree().get_first_node_in_group("camera")
	if cam:
		if global_position.x > cam.global_position.x:
			cam.position.x = position.x
	
	var cloud = get_tree().get_first_node_in_group("cloud")
	if position.y > cloud.position.y:
		position = cloud.position + Vector2(0, -1500)

func _start_wind_minigame() -> void:
	_wind_minigame = WindMinigameScene.instantiate()
	add_child(_wind_minigame)


func _resolve_wind_minigame() -> void:
	var direction := _wind_minigame.resolve()
	_wind_minigame = null

	if direction != 0:
		var cloud := get_tree().get_first_node_in_group("cloud")
		if cloud:
			cloud.apply_wind(direction, wind_force)


func _start_weather_minigame() -> void:
	_weather_minigame = WeatherMinigameScene.instantiate()
	add_child(_weather_minigame)


func _resolve_weather_minigame() -> void:
	var direction := _weather_minigame.resolve()
	_weather_minigame = null

	if direction != 0:
		var cloud := get_tree().get_first_node_in_group("cloud")
		if cloud:
			cloud.apply_weather(direction, 260)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("rain_cloud"):
		body.queue_free()
		var cloud := get_tree().get_first_node_in_group("cloud")
		if cloud:
			cloud.fill_water()
