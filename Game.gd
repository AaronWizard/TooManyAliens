extends Node

onready var _enemies := $EnemyWave

var _explosion_scene := preload("res://Explosion.tscn")


func _on_Player_died(position: Vector2) -> void:
	yield(_add_explosion(position), "completed")
	print("game over")


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


func _on_shot_firedt(bullet: Bullet) -> void:
	# warning-ignore:return_value_discarded
	bullet.connect("exploded", self, "_on_bullet_collision", [bullet])
	add_child(bullet)


func _on_EnemyWave_enemy_died(position) -> void:
	_add_explosion(position)


func _on_EnemyWave_wave_cleared() -> void:
	print("you win")
