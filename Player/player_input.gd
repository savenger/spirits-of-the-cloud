class_name PlayerInput
extends RefCounted


var device: InputDevice

var move_direction: float = 0.0

var jump_pressed: bool = false
var cancel_pressed: bool = false
var call_wind_pressed: bool = false
var influence_weather_pressed: bool = false


func _init(input_device: InputDevice):
	device = input_device


func get_move_direction() -> float:
	return move_direction


func is_jump_just_pressed() -> bool:
	var result := jump_pressed
	jump_pressed = false
	return result


func is_cancel_just_pressed() -> bool:
	var result := cancel_pressed
	cancel_pressed = false
	return result


func is_call_wind_just_pressed() -> bool:
	var result := call_wind_pressed
	call_wind_pressed = false
	return result


func is_influence_weather_just_pressed() -> bool:
	var result := influence_weather_pressed
	influence_weather_pressed = false
	return result
