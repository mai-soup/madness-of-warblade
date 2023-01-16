extends Control

const format_string = "x%d"

onready var count_label := $HBoxContainer/Label
var current_potions : int setget set_potion

func _ready() -> void:
	self.set_potion(0)
	PlayerHealthMgr.connect("potions_increased", self, "set_potion")

func set_potion(new = -66):
	if new == -1:
		if current_potions - 1 < 0: return
		if PlayerHealthMgr.current_health == PlayerHealthMgr.max_health: return
		
		current_potions -= 1
		PlayerHealthMgr.current_health += 1
		$AudioStreamPlayer.play()
	elif new == -66:
		if current_potions + 1 > 9: return
		current_potions += 1
	else:
		if new < 0:
			current_potions = 0
		elif new > 9:
			current_potions = 9
		else:
			current_potions = new
	
	count_label.text = format_string % current_potions
