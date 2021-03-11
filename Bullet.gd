class_name Bullet
extends Area2D

export var speed := 400 # Pixels per second


func _physics_process(delta: float) -> void:
	var velocity := Vector2(0, -speed * delta)
	position += velocity


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()
