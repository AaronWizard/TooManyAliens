class_name Explosion
extends CPUParticles2D

signal explosion_finished


func _ready() -> void:
	emitting = true


func _on_Timer_timeout() -> void:
	emit_signal("explosion_finished")
	queue_free()
