class_name PauseScreen
extends ColorRect

signal unpaused


func _on_Button_pressed() -> void:
	_unpause()


func _unpause() -> void:
	emit_signal("unpaused")
