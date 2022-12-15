extends Control

const HEART_SIZE: = 8

onready var empty: = $HeartsEmpty
onready var full: = $HeartsFull
var max_health
var current_health

func _ready() -> void:
	self.current_health = get_tree().current_scene.get_node("YSort/Player/HealthManager").current_health
	self.max_health = get_tree().current_scene.get_node("YSort/Player/HealthManager").max_health

func update_max(new: int) -> void:
	max_health = max(1, new)
	empty.rect_size.x = max_health * HEART_SIZE

func update_current(new: int) -> void:
	current_health = clamp(new, 0, max_health)
	full.rect_size.x = current_health * HEART_SIZE
