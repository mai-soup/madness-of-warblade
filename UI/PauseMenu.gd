extends Control

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause"):
		toggle_pause_state()

func _on_ResumeButton_pressed() -> void:
	toggle_pause_state()

func toggle_pause_state() -> void:
	var new_state = !get_tree().paused
	if new_state:
		$VBoxContainer/ResumeButton.grab_focus()
	get_tree().paused = new_state
	visible = new_state

func _on_QuitButton_pressed() -> void:
	get_tree().change_scene("res://UI/MainMenu.tscn")
	toggle_pause_state()
