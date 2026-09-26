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

	player_1.set_physics_process(false)
	player_2.set_physics_process(false)

	input_manager.player_joined.connect(_on_player_joined)
	$Mainmenu.game_start.connect(start_game)

func start_game():
	$Mainmenu.visible = false
	reset_level()

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

	elif player_id == 2:
		player_2.spirit_type = 1
		player_2.input = player_input
		player_2.can_call_wind = true
		player_2.can_influence_weather = false
		player_2.show()
		player_2.set_physics_process(true)
