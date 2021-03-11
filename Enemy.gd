class_name Enemy
extends Area2D

export var shoot_rate := 1 # Shots per second

var _bullet_scene := preload("res://EnemyBullet.tscn")

onready var _shoot_timer := $ShootTimer as Timer


func _ready() -> void:
	_shoot_timer.wait_time = 1.0 / float(shoot_rate)
	call_deferred("_start_shooting")


func _start_shooting() -> void:
	randomize()
	var start_time := rand_range(0, 2)
	yield(get_tree().create_timer(start_time), "timeout")
	_shoot_timer.start()


func _on_ShootTimer_timeout() -> void:
	var bullet := _bullet_scene.instance() as Bullet
	bullet.position = position
	owner.add_child(bullet)


func _on_Enemy_area_entered(area: Area2D) -> void:
	queue_free()
