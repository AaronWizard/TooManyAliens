extends Node


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_Start_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://src/game/Game.tscn")


func _on_Quit_pressed() -> void:
	get_tree().quit()
