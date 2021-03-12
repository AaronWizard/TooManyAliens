class_name Explosion
extends CPUParticles2D

signal explosion_finished

onready var _sound := $AudioStreamPlayer as AudioStreamPlayer


func _ready() -> void:
	emitting = true


func _on_Timer_timeout() -> void:
	if _sound.playing:
		yield(_sound, "finished")
	emit_signal("explosion_finished")
	queue_free()
