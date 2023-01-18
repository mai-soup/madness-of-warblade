extends Node2D

var is_opened: = false

func _on_Area2D_body_entered(body: Node) -> void:
	if is_opened: return
	is_opened = true
	$AnimationPlayer.play("Open")

func animation_ended() -> void:
	PlayerHealthMgr.increase_potions()
