class_name Bullet
extends Area2D

signal exploded(other)

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


func _on_Bullet_area_entered(area: Area2D) -> void:
	if area is Enemy:
		var enemy := area as Enemy
		enemy.die()
		queue_free()
	else: # area is Bullet:
		emit_signal("exploded", area)

	queue_free()


func _on_Bullet_body_entered(body: Node) -> void:
	if body is Player:
		var player := body as Player
		player.die()
	queue_free()
