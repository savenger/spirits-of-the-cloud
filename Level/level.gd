extends Node2D

var field_template = preload("res://Level/field.tscn")
var cloud_template = preload("res://Level/rain_cloud.tscn")
var tree_template = preload("res://Level/tree.tscn")
var hill_templates = [
	preload("res://Level/hill1.tscn"),
	preload("res://Level/hill2.tscn")
]

var cloud_area_size = Global.CLOUD_AREA_RIGHT - Global.CLOUD_AREA_LEFT

var _spawned_nodes: Array[Node2D] = []

func spawn_clouds(cloud_offset):
	var rect_size = cloud_area_size / Global.CLOUD_COUNT_PER_ROW
	var cloud_offset_x = Global.CLOUD_AREA_LEFT + cloud_offset
	var cloud_offset_y = Global.CLOUD_AREA_TOP
	for r in range(Global.CLOUD_ROWS):
		for n in range(Global.CLOUD_COUNT_PER_ROW):
			# define rect for cloud instance
			var cloud : Node2D = cloud_template.instantiate()
			add_child(cloud)
			cloud.global_position = Vector2(cloud_offset_x + randf() * rect_size, cloud_offset_y + randf() * rect_size)
			cloud_offset_x += rect_size
			_spawned_nodes.append(cloud)
		cloud_offset_y += rect_size

func spawn_field(field_offset):
	var field : Node2D = field_template.instantiate()
	add_child(field)
	field.position = Vector2(field_offset + randf() * 100, $MarkerGround.position.y)
	_spawned_nodes.append(field)
	return field.position.x

func spawn_trees(tree_offset):
	for t in range(Global.TREE_COUNT):
		tree_offset = tree_offset + randf() * 1750
		var tree: Node2D = tree_template.instantiate()
		add_child(tree)
		tree.position = Vector2(tree_offset, $MarkerGround.position.y - 75)
		tree.z_index = -1
		_spawned_nodes.append(tree)

func spawn_hill(hill_offset):
	if true: #if randf() <= 0.4:
		var hill: Node2D = hill_templates.pick_random().instantiate()
		add_child(hill)
		hill.position = Vector2(hill_offset, $MarkerGround.position.y)
		hill.z_index = -1
		_spawned_nodes.append(hill)

## Clears all dynamically spawned fields/clouds/trees and spawns a fresh set.
func reload():
	for n in _spawned_nodes:
		if is_instance_valid(n):
			n.queue_free()
	_spawned_nodes.clear()

	spawn_field(0)
	spawn_clouds(0)
	spawn_trees(0)
	spawn_hill(0)

func _ready():
	spawn_field(0)
	spawn_clouds(0)
	spawn_trees(0)
	spawn_hill(0)

	Global.field_fully_watered.connect(generate_new_field)

func generate_new_field(offset: int):
	spawn_trees(offset + Global.VIEW_WIDTH)
	spawn_field(offset + Global.VIEW_WIDTH)
	spawn_clouds(offset + Global.VIEW_WIDTH)
	spawn_hill(offset + Global.VIEW_WIDTH)
