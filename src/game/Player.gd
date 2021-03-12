class_name Player
extends KinematicBody2D

signal shoot(bullet_scene, position)
signal died(position)

export var speed := 400 # Pixels per second
export var shoot_rate := 4 # Shots per second

export var move_threshold := 5

var _bullet_scene := load("res://src/game/Bullet.tscn")

onready var _bullet_timer := $BulletTimer as Timer

var _dead: bool


func _ready() -> void:
	_dead = false
	_bullet_timer.wait_time = 1.0 / float(shoot_rate)


func _physics_process(delta: float) -> void:
	if not _dead:
		_move(delta)


func _unhandled_input(event: InputEvent) -> void:
	if not _dead and event.is_action_pressed("shoot"):
		_shoot()


func die() -> void:
	if not _dead:
		emit_signal("died", global_position)
		_dead = true
		_bullet_timer.stop()
		visible = false


func respawn(new_position: Vector2) -> void:
	position = new_position
	visible = true
	_dead = false


func _move(delta: float) -> void:
	var mouse_diff := get_viewport().get_mouse_position() - position
	if abs(mouse_diff.x) > move_threshold:
		var move_dir := sign(mouse_diff.x)
		var move_speed := move_dir * speed
		var velocity := Vector2(move_speed * delta, 0)
		# warning-ignore:return_value_discarded
		move_and_collide(velocity)


func _shoot() -> void:
	if _bullet_timer.is_stopped():
		emit_signal("shoot", _bullet_scene, global_position)
		_bullet_timer.start()
