extends Control

func _ready() -> void:
	$MarginContainer/VBoxContainer/StartBtn.grab_focus()

func _on_StartBtn_pressed() -> void:
	get_tree().change_scene("res://World.tscn")

func _on_CreditsBtn_pressed() -> void:
	get_tree().change_scene("res://UI/CreditsMenu.tscn")

func _on_QuitBtn_pressed() -> void:
	get_tree().quit()
