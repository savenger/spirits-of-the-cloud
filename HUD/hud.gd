extends CanvasLayer

func _ready() -> void:
	Global.field_fully_watered.connect(on_field_fully_watered)
	Global.field_lost.connect(on_field_lost)

func on_field_fully_watered(offset):
	Global.fields_saved += 1
	update_stats()

func on_field_lost(offset):
	Global.fields_lost += 1
	update_stats()

func update_stats():
	$Stats/lblWateredFields.text = "Saved Fields: " + str(Global.fields_saved)
	$Stats/lblDriedOutFields.text = "Lost Fields: " + str(Global.fields_lost)
