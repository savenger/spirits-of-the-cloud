extends Node2D

var trees = [
	"res://Assets/Tree1.png",
	"res://Assets/Tree2.png",
	"res://Assets/Tree3.png"
]

func _ready() -> void:
	$Sprite2D.texture = load(trees.pick_random())
	$Sprite2D.position.y -= $Sprite2D.get_rect().size.y
	add_to_group("tree")
