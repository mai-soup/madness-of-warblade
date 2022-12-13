extends Control

onready var label: = $HeartsLabel
var max_health
var current_health

const format: = "HP: %s/%s"

func _ready() -> void:
	max_health = get_tree().current_scene.get_node("YSort/Player/HealthManager").max_health
	current_health = get_tree().current_scene.get_node("YSort/Player/HealthManager").current_health
	update_text()

func update_max(new: int) -> void:
	max_health = new
	
func update_current(new: int) -> void:
	current_health = new
	update_text()

func update_text() -> void:
	label.text = format % [current_health, max_health]
