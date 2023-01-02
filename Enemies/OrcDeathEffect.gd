extends Node2D

func _ready() -> void:
	$AnimatedSprite.frame = 0
	$AnimatedSprite.playing = true

func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
