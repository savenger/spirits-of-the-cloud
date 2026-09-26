class_name InputDevice
extends RefCounted


enum Type {
	KEYBOARD,
	GAMEPAD
}


var type: Type
var device_id: int


func _init(device_type: Type, id: int = -1):
	type = device_type
	device_id = id
