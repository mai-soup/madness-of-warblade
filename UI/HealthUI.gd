extends Control

const HEART_SIZE: = 8

onready var empty: = $HeartsEmpty
onready var full: = $HeartsFull
var max_health setget update_max
var current_health setget update_current

func _ready() -> void:
	self.max_health = PlayerHealthMgr.max_health
	self.current_health = PlayerHealthMgr.current_health
	PlayerHealthMgr.connect("health_changed", self, "update_current")

func update_max(new: int) -> void:
	max_health = max(1, new)
	empty.rect_size.x = max_health * HEART_SIZE

func update_current(new: int) -> void:
	current_health = clamp(new, 0, max_health)
	full.rect_size.x = current_health * HEART_SIZE
	print("update health with " + str(new) + ", size is " + str(full.rect_size.x))
