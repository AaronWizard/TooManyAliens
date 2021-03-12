extends AudioStreamPlayer

func _on_BulletSound_finished() -> void:
	queue_free()
