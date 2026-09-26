extends Node2D

var plant_sprites = [
	"res://Assets/Plant1.png",
]

var plant_shader = preload("res://Level/field.gdshader")

@onready var _watering_effect: GPUParticles2D = $WateringEffect

@export var tint_strength := 1.0:
	set(value):
		tint_strength = value
		if _material:
			_material.set_shader_parameter("tint_strength", tint_strength)

var _material: ShaderMaterial

var timer_dry_out = Timer.new()

func _ready():
	$Sprite2D.texture = load(plant_sprites.pick_random())

	_material = ShaderMaterial.new()
	_material.shader = plant_shader
	_material.set_shader_parameter("tint_strength", tint_strength)
	$Sprite2D.material = _material
	scale.x = randf_range(0.8, 1.2)
	scale.y = randf_range(0.8, 1.2)
	add_to_group("plant")
	$Sprite2D.position.y -= $Sprite2D.get_rect().size.y
	
	timer_dry_out.timeout.connect(_on_timer_dry_out_timeout)
	timer_dry_out.wait_time = 4
	add_child(timer_dry_out)

func dry_out():
	$Sprite2D.visible = false
	$DryEffect.restart()
	timer_dry_out.start()

func _on_timer_dry_out_timeout():
	queue_free()

func fully_watered():
	_watering_effect.restart()
	_watering_effect.emitting = true
