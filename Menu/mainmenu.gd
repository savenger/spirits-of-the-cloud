extends Control

signal game_start

func hide_all_menus():
	$MenuContainer.visible = false

func _on_btn_start_pressed() -> void:
	hide_all_menus()
	game_start.emit()


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
