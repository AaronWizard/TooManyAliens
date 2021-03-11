class_name Player
extends KinematicBody2D

export var speed := 400 # Pixels per second
export var shoot_rate := 4 # Shots per second

export var move_threshold := 5

var _bullet_scene := preload("res://Bullet.tscn")

onready var _bullet_timer := $BulletTimer as Timer


func _ready() -> void:
	_bullet_timer.wait_time = 1.0 / float(shoot_rate)


func _physics_process(delta: float) -> void:
	var mouse_diff := get_viewport().get_mouse_position() - position
	if abs(mouse_diff.x) > move_threshold:
		var move_dir := sign(mouse_diff.x)
		var move_speed := move_dir * speed
		var velocity := Vector2(move_speed * delta, 0)
		# warning-ignore:return_value_discarded
		move_and_collide(velocity)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		_shoot()


func _shoot() -> void:
	if _bullet_timer.is_stopped():
		var bullet := _bullet_scene.instance() as Bullet
		bullet.position = position
		owner.add_child(bullet)
		_bullet_timer.start()
