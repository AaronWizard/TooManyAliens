extends Node


func _on_Start_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://src/game/Game.tscn")


func _on_Quit_pressed() -> void:
	get_tree().quit()
