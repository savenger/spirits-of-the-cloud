extends Node2D

var animal_sprites = [
	"res://Assets/Animal1.png"
]

func _ready():
	$Sprite2D.texture = load(animal_sprites.pick_random())
	$Sprite2D.position.y -= $Sprite2D.get_rect().size.y
