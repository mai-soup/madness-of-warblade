extends Control

func _ready() -> void:
	$MarginContainer/VBoxContainer/Button.grab_focus()

func _on_Button_pressed() -> void:
	get_tree().change_scene("res://UI/MainMenu.tscn")
