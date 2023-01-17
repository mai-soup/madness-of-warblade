extends Node2D

export var text: String

func _ready() -> void:
	$TextOverlay.visible = false
	$TextOverlay.get_child(0).text = text

func _on_body_entered(body: Node) -> void:
	$TextOverlay.visible = true

func _on_body_exited(body: Node) -> void:
	$TextOverlay.visible = false
