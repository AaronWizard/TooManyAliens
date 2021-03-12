class_name Gui
extends CanvasLayer

signal unpaused

const _WAVE_ANNOUNCE_TEXT := "Wave %d approaching"
const _WAVE_ANNOUNCE_TIME := 2.0

onready var _lives_count := $Lives/LivesCount as Label
onready var _pause_screen := $PauseScreen as PauseScreen
onready var _wave_text := $WaveAnnouncement/Label as Label
onready var _game_over := $GameOver as CanvasItem

func set_lives_count(count: int) -> void:
	_lives_count.text = str(count)


func show_pause() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	_pause_screen.visible = true


func show_wave_announcement(wave: int) -> void:
	_wave_text.text = _WAVE_ANNOUNCE_TEXT % wave
	_wave_text.visible = true
	yield(get_tree().create_timer(_WAVE_ANNOUNCE_TIME), "timeout")
	_wave_text.visible = false


func show_game_over() -> void:
	_game_over.visible = true


func _on_PauseScreen_unpaused() -> void:
	_pause_screen.visible = false
	get_tree().paused = false
	emit_signal("unpaused")
