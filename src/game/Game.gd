extends Node

const _WAVES_DIR := "res://src/waves/"

var _explosion_scene := preload("res://src/game/Explosion.tscn")

var _waves: Array
var _wave_index: int

var _player_dying: bool

var _current_wave: EnemyWave

onready var _pause := $PauseScreen as CanvasItem
onready var _game_over := $GameOver as CanvasItem


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	_waves = _get_waves()
	_wave_index = 0

	_player_dying = false

	_load_wave()


func _unhandled_input(event: InputEvent) -> void:
	if not _player_dying and event.is_action_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		_pause.visible = true


func _load_wave() -> void:
	var wave_path := _waves[_wave_index] as String
	var wave_scene := load(wave_path) as PackedScene
	_current_wave = wave_scene.instance() as EnemyWave

	# warning-ignore:return_value_discarded
	_current_wave.connect("shot_fired", self, "_on_shot_fired")
	# warning-ignore:return_value_discarded
	_current_wave.connect("enemy_died", self, "_on_enemy_died")
	# warning-ignore:return_value_discarded
	_current_wave.connect("wave_cleared", self, "_on_wave_cleared")

	add_child(_current_wave)


func _clear_wave() -> void:
	_current_wave.queue_free()
	_wave_index = (_wave_index + 1) % _waves.size()


static func _get_waves() -> Array:
	var result := []

	var directory := Directory.new()
	var error := directory.open(_WAVES_DIR)
	if error == OK:
		# warning-ignore:return_value_discarded
		directory.list_dir_begin(true, true)
		var file_name := directory.get_next()
		while file_name != "":
			assert(not directory.current_is_dir())
			result.append(_WAVES_DIR + file_name)

			file_name = directory.get_next()
	else:
		print("Error opening waves directory '%s'" % _WAVES_DIR)

	return result


func _add_explosion(position: Vector2) -> void:
	var explosion := _explosion_scene.instance() as Explosion
	explosion.position = position
	add_child(explosion)
	yield(explosion, "explosion_finished")


func _on_Player_died(position: Vector2) -> void:
	_player_dying = true

	yield(_add_explosion(position), "completed")
	_game_over.visible = true
	yield(get_tree().create_timer(2), "timeout")
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://src/start/Start.tscn")


func _on_shot_fired(bullet: Bullet) -> void:
	# warning-ignore:return_value_discarded
	bullet.connect("exploded", self, "_on_bullet_collision", [bullet])
	add_child(bullet)


func _on_bullet_collision(bullet: Bullet, other_bullet: Bullet) -> void:
	# Make sure there is only one explosion
	if bullet.is_connected("exploded", self, "_on_bullet_collision"):
		bullet.disconnect("exploded", self, "_on_bullet_collision")
	if other_bullet.is_connected("exploded", self, "_on_bullet_collision"):
		other_bullet.disconnect("exploded", self, "_on_bullet_collision")

	var midpoint := ((bullet.position - other_bullet.position) / 2) \
			+ bullet.position

	_add_explosion(midpoint)


func _on_enemy_died(position) -> void:
	_add_explosion(position)


func _on_wave_cleared() -> void:
	_clear_wave()
	yield(get_tree().create_timer(1.0), "timeout")
	_load_wave()


func _on_PauseScreen_unpaused() -> void:
	_pause.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
