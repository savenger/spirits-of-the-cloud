extends Node2D


@onready var input_manager: InputManager = $InputManager
@onready var player_1: CharacterBody2D = $World/Player1
@onready var player_2: CharacterBody2D = $World/Player2


func reset_level():
	$World/Level.reload()

func _ready() -> void:
	reset_level()
	player_1.hide()
	player_2.hide()
	
	player_1.position = $World/Cloud.position + Vector2(-200, -1500)
	player_2.position = $World/Cloud.position + Vector2(200, -1500)

	player_1.set_physics_process(false)
	player_2.set_physics_process(false)

	input_manager.player_joined.connect(_on_player_joined)
	input_manager.player_removed.connect(_on_player_removed)
	$Mainmenu.game_start.connect(start_game)
	Global.pause.connect(handle_pause)
	Global.game_over.connect(handle_game_over)

func handle_pause(paused: bool):
	$Mainmenu.visible = paused

func handle_game_over():
	$Mainmenu.visible = true

func start_game():
	Global.reset()
	while input_manager.get_player_count() > 0:
		input_manager.remove_player(input_manager.get_player_count())
	$Mainmenu.visible = false

func _on_player_removed(player_id: int):
	if player_id == 1:
		player_1.hide()
		player_1.set_physics_process(false)
		player_1.input = null
		$Hud/lblPlayer1.visible = true
		$Hud/Stats.visible = false
	if player_id == 2:
		player_1.can_call_wind = true
		player_2.hide()
		player_2.set_physics_process(false)
		player_2.input = null
		$Hud/lblPlayer2.visible = true

func _on_player_joined(
	player_id: int,
	player_input: PlayerInput
) -> void:

	if player_id == 1:
		player_1.input = player_input
		player_1.can_call_wind = true
		player_1.can_influence_weather = true
		player_1.show()
		player_1.set_physics_process(true)
		$Hud/lblPlayer1.visible = false
		$Hud/Stats.visible = true

	elif player_id == 2:
		player_2.spirit_type = 1
		player_2.input = player_input
		player_2.can_call_wind = true
		player_2.can_influence_weather = false
		player_1.can_call_wind = false
		player_2.show()
		player_2.set_physics_process(true)
		$Hud/lblPlayer2.visible = false
