extends Camera2D

@export var object1 : Node
@export var object2 : Node

func _ready():
	pass

func _process(_delta):
	if object2.is_physics_processing():
		self.global_position = (object1.global_position + object2.global_position) * 0.5
	else:
		self.global_position = object1.global_position
