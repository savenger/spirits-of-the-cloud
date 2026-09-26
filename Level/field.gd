extends Node2D

var water_level := 2.0

var plant_template = preload("res://Level/plant.tscn")
var flower_template = preload("res://Level/flower.tscn")
var animal_template = preload("res://Level/animal.tscn")

const WATER_LEVEL_MAX = 10.0
const PLANT_OFFSET_X_BASE = 500.0
const PLANT_OFFSET_X = 150.0
const PLANT_COUNT_MIN = 10
const PLANT_COUNT_MAX = 15

var field_center = Vector2(0, 0)
var _fully_watered := false

var timer = Timer.new()

func spawn_plant(plant_offset):
	var plant : Node2D = plant_template.instantiate()
	add_child(plant)
	plant.position = Vector2(plant_offset + randf() * 100, 100)
	return plant.position.x

func spawn_flower(plant_offset):
	var flower : Node2D = flower_template.instantiate()
	add_child(flower)
	flower.position = Vector2(plant_offset + randf() * 100, 0)
	return flower.position.x
		
func spawn_animal(animal_offset, flipped = false):
	var animal : Node2D = animal_template.instantiate()
	add_child(animal)
	animal.position = Vector2(animal_offset + randf() * 100, 100)
	animal.z_index = 1
	if flipped:
		animal.get_node("Sprite2D").flip_h = true
	return animal.position.x

func generate_field():
	var plant_offset = PLANT_OFFSET_X_BASE
	var plant_count = PLANT_COUNT_MIN + randi() % (PLANT_COUNT_MAX - PLANT_COUNT_MIN)
	
	plant_offset = spawn_animal(plant_offset) + PLANT_OFFSET_X
	
	for i in range(plant_count):
		if randf() <= 0.5:
			plant_offset = spawn_plant(plant_offset)
			plant_offset = spawn_flower(plant_offset)
		else:
			plant_offset = spawn_flower(plant_offset)
			plant_offset = spawn_plant(plant_offset)
	
	spawn_animal(plant_offset, true)
	
	field_center.x = PLANT_OFFSET_X_BASE + (plant_offset - PLANT_OFFSET_X_BASE) / 2

func _ready():
	generate_field()
	timer.wait_time = 0.4
	timer.timeout.connect(_on_timer_fade_timeout)
	add_child(timer)
	timer.start()

func _on_timer_fade_timeout():
	water_level -= 0.1
	update_fade_status()
	if water_level <= 0.0:
		timer.stop()

func update_fade_status():
	for n in get_children():
		if n.is_in_group("plant"):
			n.tint_strength = (10.0 - water_level) / 10.0

func add_water(delta: float):
	timer.stop()
	water_level += delta
	if water_level > WATER_LEVEL_MAX:
		water_level = WATER_LEVEL_MAX
	
	update_fade_status()

	if water_level >= WATER_LEVEL_MAX:
		if not _fully_watered:
			Global.field_fully_watered.emit(global_position.x)
			_fully_watered = true
			for n in get_children():
				if n.is_in_group("plant"):
					n.fully_watered()
				if n.is_in_group("flower"):
					n.visible = true
	else:
		_fully_watered = false
	
	timer.start()

func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	var excludes = []
	for p in players:
		excludes.append(p.get_rid())
	var space_state = get_world_2d().direct_space_state
	# field_center is local to this node, so convert to global before raycasting
	var origin = to_global(field_center)
	var query = PhysicsRayQueryParameters2D.create(origin, origin + Vector2(0, -5000), 0x02, excludes)

	var result = space_state.intersect_ray(query)
	if result:
		if result.collider.name == "Cloud":
			if result.collider.raining():
				add_water(delta)
