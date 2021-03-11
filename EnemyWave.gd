class_name EnemyWave
extends Node

signal shot_fired(bullet)
signal enemy_died(position)
signal wave_cleared

onready var _enemies := $Enemies as Node


func _ready() -> void:
	for e in _enemies.get_children():
		var enemy := e as Enemy
		# warning-ignore:return_value_discarded
		enemy.connect("shoot", self, "_on_shoot")
		# warning-ignore:return_value_discarded
		enemy.connect("died", self, "_on_enemy_died", [], CONNECT_ONESHOT)


func _on_shoot(bullet: Bullet) -> void:
	emit_signal("shot_fired", bullet)


func _on_enemy_died(position: Vector2) -> void:
	emit_signal("enemy_died", position)
	if _enemies.get_child_count() == 0:
		emit_signal("wave_cleared")
