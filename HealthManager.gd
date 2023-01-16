extends Node2D

signal died
signal health_changed(val)
signal potions_increased(val)

export var max_health: = 2
onready var potions: = 0 setget increase_potions
onready var current_health: = max_health setget update_current_health

func update_current_health(new: int) -> void:
	current_health = new
	emit_signal("health_changed", current_health)
	
	if current_health <= 0:
		emit_signal("died")

func increase_potions(val: int = 1) -> void:
	if val > 0:
		potions += 1
		emit_signal("potions_increased")
	else:
		potions -= 1
		emit_signal("potions_increased", -1)
