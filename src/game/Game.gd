extends Node

enum State {
	LOADING_LEVEL,
	GAMEPLAY,
	PAUSE,
	GAME_OVER
}

const _WAVES_DIR := "res://src/waves/"
const _WAVE_ANNOUNCE_TEXT := "Wave %d approaching"
const _WAVE_ANNOUNCE_TIME := 2.0

const _GAME_OVER_TIME := 2.0

var _explosion_scene := preload("res://src/game/Explosion.tscn")

var _waves: Array
var _wave_index: int
var _wave_count: int

var _state: int

var _current_wave: EnemyWave

onready var _pause_screen := $PauseScreen as CanvasItem

onready var _wave_announcement_label := $WaveAnnouncement/Label as Label

onready var _game_over := $GameOver as CanvasItem


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	_waves = _get_waves()
	_wave_index = 0
	_wave_count = 0

	_state = State.LOADING_LEVEL
	_load_wave()


func _unhandled_input(event: InputEvent) -> void:
	if (_state == State.GAMEPLAY) and event.is_action_pressed("pause"):
		_pause()


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		_pause()


func _load_wave() -> void:
	_state = State.LOADING_LEVEL

	_wave_count += 1
	_wave_announcement_label.text = _WAVE_ANNOUNCE_TEXT % _wave_count
	_wave_announcement_label.visible = true
	yield(get_tree().create_timer(_WAVE_ANNOUNCE_TIME), "timeout")
	_wave_announcement_label.visible = false

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
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	_pause_screen.visible = true


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
	_state = State.GAME_OVER

	yield(_add_explosion(position), "completed")
	_game_over.visible = true
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


func _on_wave_cleared() -> void:
	_clear_wave()
	if _state == State.GAMEPLAY:
		_load_wave()


func _on_PauseScreen_unpaused() -> void:
	_pause_screen.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
