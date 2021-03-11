class_name Bullet
extends Area2D

enum Direction { UP, DOWN }

export var speed := 400 # Pixels per second
export(Direction) var direction := Direction.UP


func _physics_process(delta: float) -> void:
	var velocity := Vector2(0, speed * delta)

	match direction:
		Direction.UP:
			velocity.y *= -1

	position += velocity


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()


func _on_Bullet_area_entered(_area: Area2D) -> void:
	queue_free()


func _on_Bullet_body_entered(_body: Node) -> void:
	queue_free()
