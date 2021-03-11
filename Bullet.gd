class_name Bullet
extends Area2D

enum Direction { UP, DOWN }

export var speed := 400 # Pixels per second
export(Direction) var direction := Direction.UP

var _explosion_scene := preload("res://Explosion.tscn")


func _physics_process(delta: float) -> void:
	var velocity := Vector2(0, speed * delta)

	match direction:
		Direction.UP:
			velocity.y *= -1

	position += velocity


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()


func _on_Bullet_area_entered(_area: Area2D) -> void:
	_explode()


func _on_Bullet_body_entered(body: Node) -> void:
	if body is Player:
		var player := body as Player
		player.die()
	queue_free()


func _explode() -> void:
	var explosion := _explosion_scene.instance() as Node2D
	explosion.position = position
	if owner:
		owner.add_child(explosion)
	queue_free()
