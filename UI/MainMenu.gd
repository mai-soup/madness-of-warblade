extends Control

func _ready() -> void:
	$MarginContainer/VBoxContainer/StartBtn.grab_focus()

func _on_StartBtn_pressed() -> void:
	get_tree().change_scene("res://World.tscn")

func _on_CreditsBtn_pressed() -> void:
	pass # Replace with function body.

func _on_QuitBtn_pressed() -> void:
	get_tree().quit()
