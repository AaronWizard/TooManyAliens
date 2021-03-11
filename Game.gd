extends Node

onready var _enemies := $Enemies

var _explosion_scene := preload("res://Explosion.tscn")


func _ready() -> void:
	for e in _enemies.get_children():
		var enemy := e as Enemy
		# warning-ignore:return_value_discarded
		enemy.connect("shoot", self, "_on_shoot")
		# warning-ignore:return_value_discarded
		enemy.connect("died", self, "_on_enemy_died", [], CONNECT_ONESHOT)


func _on_Player_died(position: Vector2) -> void:
	yield(_add_explosion(position), "completed")
	print("game over")


func _on_enemy_died(position: Vector2) -> void:
	_add_explosion(position)
	if _enemies.get_child_count() == 0:
		print("you win")


func _on_bullet_collision(bullet: Bullet, other_bullet: Bullet) -> void:
	# Make sure there is only one explosion
	if bullet.is_connected("exploded", self, "_on_bullet_collision"):
		bullet.disconnect("exploded", self, "_on_bullet_collision")
	if other_bullet.is_connected("exploded", self, "_on_bullet_collision"):
		other_bullet.disconnect("exploded", self, "_on_bullet_collision")

	var midpoint := ((bullet.position - other_bullet.position) / 2) \
			+ bullet.position

	_add_explosion(midpoint)


func _add_explosion(position: Vector2) -> void:
	var explosion := _explosion_scene.instance() as Explosion
	explosion.position = position
	add_child(explosion)
	yield(explosion, "explosion_finished")


func _on_shoot(bullet: Bullet) -> void:
	# warning-ignore:return_value_discarded
	bullet.connect("exploded", self, "_on_bullet_collision", [bullet])
	add_child(bullet)
