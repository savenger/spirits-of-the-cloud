extends Node2D

var plant_sprites = [
	"res://Assets/Plant2.png",
]

var timer_dry_out = Timer.new()

func _ready():
	$Sprite2D.texture = load(plant_sprites.pick_random())

	visible = false
	
	scale.x = randf_range(1.2, 2.2)
	scale.y = randf_range(1.2, 2.2)
	add_to_group("flower")
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
