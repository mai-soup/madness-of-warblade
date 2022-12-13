extends Area2D

var player = null

func can_see_player():
	return player != null

func _on_PlayerDetector_body_entered(body: Node) -> void:
	player = body

func _on_PlayerDetector_body_exited(_body: Node) -> void:
	player = null
