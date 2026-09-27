extends CanvasLayer

var timer = Timer.new()

func _ready() -> void:
	Global.field_fully_watered.connect(on_field_fully_watered)
	Global.field_lost.connect(on_field_lost)
	timer.wait_time = 3
	timer.one_shot = true
	timer.timeout.connect(hide_field_info)
	add_child(timer)

func hide_field_info():
	$lblNextField.visible = false

func on_field_fully_watered(offset):
	Global.fields_saved += 1
	update_stats()
	$lblNextField.visible = true
	timer.start()

func on_field_lost(offset):
	Global.fields_lost += 1
	update_stats()
	
	if Global.fields_lost >= Global.FIELDS_LOST_MAX:
		Global.game_over.emit()
	else:
		$lblNextField.visible = true
		timer.start()

func update_stats():
	$Stats/lblWateredFields.text = "Saved Fields: " + str(Global.fields_saved)
	$Stats/lblDriedOutFields.text = "Lost Fields: " + str(Global.fields_lost)
