extends Node2D


func _ready():
	$Sprite2D.position.y -= $Sprite2D.get_rect().size.y - 50
	$CollisionShape2D.position = $Sprite2D.position
