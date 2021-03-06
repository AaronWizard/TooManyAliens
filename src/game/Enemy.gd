class_name Enemy
extends PathFollow2D

signal shoot(bullet_scene, position)
signal died(position)

export var speed := 0.2
export var shoot_rate := 0.75 # Shots per second

var _bullet_scene := load("res://src/game/EnemyBullet.tscn")

onready var _shoot_start_timer := $ShootStartTimer as Timer
onready var _shoot_timer := $ShootTimer as Timer


func _ready() -> void:
	_shoot_timer.wait_time = 1.0 / float(shoot_rate)

	randomize()
	_shoot_start_timer.wait_time = rand_range(0, 2)
	_shoot_start_timer.start()


func _process(delta: float) -> void:
	unit_offset += speed * delta


func _on_ShootStartTimer_timeout() -> void:
	_shoot_timer.start()


func _on_ShootTimer_timeout() -> void:
	emit_signal("shoot", _bullet_scene, global_position)


func _on_Area_area_entered(_area: Area2D) -> void:
	call_deferred("_die")


func _die() -> void:
	var pos := global_position
	get_parent().remove_child(self)
	emit_signal("died", pos)
	queue_free()
