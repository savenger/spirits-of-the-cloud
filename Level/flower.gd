extends Node2D

var plant_sprites = [
	"res://Assets/Plant2.png",
]

func _ready():
	$Sprite2D.texture = load(plant_sprites.pick_random())

	visible = false
	
	scale.x = randf_range(1.2, 2.2)
	scale.y = randf_range(1.2, 2.2)
	add_to_group("flower")
	$Sprite2D.position.y -= $Sprite2D.get_rect().size.y
