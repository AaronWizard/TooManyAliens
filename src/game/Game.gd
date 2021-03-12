extends Node

enum State {
	LOADING_LEVEL,
	GAMEPLAY,
	PAUSE,
	PLAYER_DEAD,
	GAME_OVER
}

const _START_LIVES := 3
const _LIFE_KILLS := 30

const _WAVES_DIR := "res://src/waves/"
const _GAME_OVER_TIME := 2.0

var _explosion_scene := preload("res://src/game/Explosion.tscn")

var _lives: int
var _kill_count: int

var _waves: Array
var _wave_index: int
var _wave_count: int

var _state: int

var _current_wave: EnemyWave

onready var _player := $Player as Player
onready var _initial_player_pos := $InitialPlayerPos
onready var _gui := $Gui as Gui


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	_lives = _START_LIVES
	_kill_count = 0

	_gui.set_lives_count(_lives)

	_waves = _get_waves()
	_wave_index = 0
	_wave_count = 0

	_state = State.LOADING_LEVEL
	_load_wave()


func _unhandled_input(event: InputEvent) -> void:
	if (_state == State.GAMEPLAY) and event.is_action_pressed("pause"):
		_pause()


func _notification(what: int) -> void:
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			_pause()
		MainLoop.NOTIFICATION_WM_MOUSE_EXIT:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		MainLoop.NOTIFICATION_WM_MOUSE_ENTER:
			if _state != State.PAUSE:
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


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


func _load_wave() -> void:
	_state = State.LOADING_LEVEL

	_wave_count += 1
	yield(_gui.show_wave_announcement(_wave_count), "completed")

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
	_state = State.GAMEPLAY


func _clear_wave() -> void:
	_current_wave.queue_free()
	_wave_index = (_wave_index + 1) % _waves.size()


func _pause() -> void:
	_state = State.PAUSE
	_gui.show_pause()


func _add_explosion(position: Vector2) -> void:
	var explosion := _explosion_scene.instance() as Explosion
	explosion.position = position
	add_child(explosion)
	yield(explosion, "explosion_finished")


func _on_Player_died(position: Vector2) -> void:
	_state = State.PLAYER_DEAD

	_lives -= 1
	_gui.set_lives_count(_lives)

	yield(_add_explosion(position), "completed")

	if _lives > 0:
		yield(get_tree().create_timer(_GAME_OVER_TIME), "timeout")
		_player.respawn(_initial_player_pos.position)
		_state = State.GAMEPLAY
	else:
		_state = State.GAME_OVER
		_gui.show_game_over()
		yield(get_tree().create_timer(_GAME_OVER_TIME), "timeout")
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://src/start/Start.tscn")


func _on_shot_fired(bullet_scene: PackedScene, bullet_pos: Vector2) -> void:
	if _state == State.GAMEPLAY:
		var bullet = bullet_scene.instance() as Bullet
		bullet.position = bullet_pos
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

	_kill_count += 1
	if _kill_count == _LIFE_KILLS:
		_kill_count = 0
		_lives += 1
		_gui.set_lives_count(_lives)


func _on_wave_cleared() -> void:
	_clear_wave()
	if _state == State.GAMEPLAY:
		_load_wave()


func _on_Gui_unpaused() -> void:
	_state = State.GAMEPLAY
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
