extends CanvasLayer

signal game_start

var bus = AudioServer.get_bus_index("Master")

func _ready() -> void:
	get_tree().paused = true
	print($MenuContainer/Sprite2D.get_rect().size)
	
	Global.game_over.connect(_on_game_over)
	Global.pause.connect(handle_pause)

func handle_pause(paused: bool):
	$PauseContainer.visible = paused

func _on_game_over():
	hide_all_menus()
	$GameOverContainer.visible = true
	get_tree().paused = true

func hide_all_menus():
	$MenuContainer.visible = false
	$ControlsContainer.visible = false
	$GameOverContainer.visible = false
	$PauseContainer.visible = false

func _on_btn_start_pressed() -> void:
	get_tree().paused = false
	hide_all_menus()
	game_start.emit()


func _on_btn_quit_pressed() -> void:
	get_tree().quit()


func _on_slider_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))


func _on_btn_controls_pressed() -> void:
	hide_all_menus()
	$ControlsContainer.visible = true

func _on_btn_close_controls_pressed() -> void:
	hide_all_menus()
	$MenuContainer.visible = true

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if not $MenuContainer.visible:
			if get_tree().paused:
				_on_btn_continue_pressed()
			else:
				Global.pause.emit(true)
				get_tree().paused = true
		if $MenuContainer.visible:
			_on_btn_start_pressed()


func _on_btn_continue_pressed() -> void:
	Global.pause.emit(false)
	get_tree().paused = false


func _on_btn_start_over_pressed() -> void:
	get_tree().reload_current_scene()
