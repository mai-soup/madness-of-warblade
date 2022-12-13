extends Area2D

var player = null

func player_in_range():
	return player != null

func _on_AttackDetector_body_entered(body: Node) -> void:
	player = body

func _on_AttackDetector_body_exited(_body: Node) -> void:
	player = null
