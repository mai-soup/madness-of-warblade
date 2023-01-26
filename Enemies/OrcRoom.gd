tool
extends Node2D

var door: Node2D = null

func _get_configuration_warning() -> String:
	if $DoorHorizontal == null and $DoorVertical == null:
		return "Room needs a horizontal or vertical door."
	
	return ""

func _ready() -> void:
	if $DoorHorizontal:
		door = $NodeHorizontal
	elif $DoorVertical:
		door = $DoorVertical
	else:
		printerr("No door found in room!")

func _process(delta: float) -> void:
	if get_child_count() <= 2:
		door.open()
