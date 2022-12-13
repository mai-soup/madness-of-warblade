extends Node2D

signal died

export var max_health: = 2
onready var current_health: = max_health setget update_current_health

func update_current_health(new: int) -> void:
	current_health = new
	
	if current_health <= 0:
		emit_signal("died")
