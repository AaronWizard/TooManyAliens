class_name Enemy
extends Area2D

signal shoot(bullet)
signal died(position)

export var shoot_rate := 1 # Shots per second

var _bullet_scene := load("res://EnemyBullet.tscn")

onready var _shoot_timer := $ShootTimer as Timer


func _ready() -> void:
	_shoot_timer.wait_time = 1.0 / float(shoot_rate)
	call_deferred("_start_shooting")


func die() -> void:
	get_parent().remove_child(self)
	emit_signal("died", position)
	queue_free()


func _start_shooting() -> void:
	randomize()
	var start_time := rand_range(0, 2)
	yield(get_tree().create_timer(start_time), "timeout")
	_shoot_timer.start()


func _on_ShootTimer_timeout() -> void:
	var bullet := _bullet_scene.instance() as Node2D
	bullet.position = position
	emit_signal("shoot", bullet)
