class_name PauseScreen
extends ColorRect

signal unpaused
signal quit


func _on_Continue_pressed() -> void:
	get_tree().paused = false
	emit_signal("unpaused")


func _on_Quit_pressed() -> void:
	get_tree().paused = false
	emit_signal("quit")


func _on_PauseScreen_visibility_changed() -> void:
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	else:
		get_tree().paused = false
