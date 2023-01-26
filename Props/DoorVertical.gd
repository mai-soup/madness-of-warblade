extends StaticBody2D

func _ready() -> void:
	close()

func open() -> void:
	$Sprite.frame = 1
	$CollisionShape2D.disabled = true
	$AudioStreamPlayer.play()

func close() -> void:
	$Sprite.frame = 0
	$CollisionShape2D.disabled = false
