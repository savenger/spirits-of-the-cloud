class_name InputManager
extends Node

signal player_joined(player_id: int, player_input: PlayerInput)

const MAX_PLAYERS := 2

var player_inputs: Dictionary = {}


func _input(event: InputEvent) -> void:
	var player_id := get_player_for_event(event)

	if player_id != -1:
		process_event(player_inputs[player_id], event)
	elif event.is_pressed():
		try_join(event)


func try_join(event: InputEvent) -> void:
	if player_inputs.size() >= MAX_PLAYERS:
		return

	var device := get_device_from_event(event)

	if device == null:
		return

	if is_device_already_assigned(device):
		return

	var player_id := find_free_player_id()

	if player_id == -1:
		return

	var player_input := PlayerInput.new(device)

	player_inputs[player_id] = player_input

	print(
		"Player %d joined with %s %d"
		% [
			player_id,
			"Keyboard" if device.type == InputDevice.Type.KEYBOARD else "Gamepad",
			device.device_id
		]
	)

	player_joined.emit(player_id, player_input)


func get_device_from_event(event: InputEvent) -> InputDevice:
	if event is InputEventKey:
		return InputDevice.new(InputDevice.Type.KEYBOARD)

	if event is InputEventJoypadButton:
		return InputDevice.new(
			InputDevice.Type.GAMEPAD,
			event.device
		)

	if event is InputEventJoypadMotion:
		if abs(event.axis_value) < 0.5:
			return null

		return InputDevice.new(
			InputDevice.Type.GAMEPAD,
			event.device
		)

	return null


func get_player_for_event(event: InputEvent) -> int:
	for player_id in player_inputs:
		var player_input: PlayerInput = player_inputs[player_id]

		if player_input.device.type == InputDevice.Type.KEYBOARD:
			if event is InputEventKey:
				return player_id

		elif player_input.device.type == InputDevice.Type.GAMEPAD:
			if event is InputEventJoypadButton:
				if event.device == player_input.device.device_id:
					return player_id

			elif event is InputEventJoypadMotion:
				if event.device == player_input.device.device_id:
					return player_id

	return -1


func process_event(
	player_input: PlayerInput,
	event: InputEvent
) -> void:

	if event.is_action_pressed("jump"):
		player_input.jump_pressed = true

	if event.is_action_pressed("cancel"):
		player_input.cancel_pressed = true

	if event.is_action_pressed("call_wind"):
		player_input.call_wind_pressed = true

	if event.is_action_pressed("influence_weather"):
		player_input.influence_weather_pressed = true

	if event.is_action_pressed("move_left"):
		player_input.move_direction = -1.0

	if event.is_action_released("move_left"):
		if player_input.move_direction < 0.0:
			player_input.move_direction = 0.0

	if event.is_action_pressed("move_right"):
		player_input.move_direction = 1.0

	if event.is_action_released("move_right"):
		if player_input.move_direction > 0.0:
			player_input.move_direction = 0.0


func find_free_player_id() -> int:
	for player_id in range(1, MAX_PLAYERS + 1):
		if not player_inputs.has(player_id):
			return player_id

	return -1


func is_device_already_assigned(device: InputDevice) -> bool:
	for player_input: PlayerInput in player_inputs.values():
		if player_input.device.type != device.type:
			continue

		if player_input.device.device_id == device.device_id:
			return true

	return false


func get_player_input(player_id: int) -> PlayerInput:
	return player_inputs.get(player_id)


func remove_player(player_id: int) -> void:
	player_inputs.erase(player_id)


func has_player(player_id: int) -> bool:
	return player_inputs.has(player_id)


func get_player_count() -> int:
	return player_inputs.size()
