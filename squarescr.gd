extends ColorRect

signal cleared
signal expired

@export var shrink_duration: float = 2.0
@export var start_scale: float = 1.5

var _tween: Tween
var _done: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	scale = Vector2(start_scale, start_scale)

	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2.ZERO, shrink_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.finished.connect(_on_shrink_finished)

func _gui_input(event: InputEvent) -> void:
	# Desktop clicks (and touches if Emulate Mouse From Touch is ON)
	if event is InputEventMouseButton and event.pressed:
		_tap()

func _input(event: InputEvent) -> void:
	# Native Android touch (works even if emulation is OFF)
	if event is InputEventScreenTouch and event.pressed:
		if get_global_rect().has_point(event.position):
			_tap()

func _tap() -> void:
	if _done:
		return
	_done = true
	if is_instance_valid(_tween):
		_tween.kill()
	emit_signal("cleared")
	queue_free()

func _on_shrink_finished() -> void:
	if _done:
		return
	_done = true
	emit_signal("expired")
	queue_free()
