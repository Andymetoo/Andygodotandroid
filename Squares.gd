extends ColorRect

signal tapped

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_STOP
	if size == Vector2.ZERO:
		size = Vector2(100, 100)
	move_to_random_position()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_score_and_move()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if get_global_rect().has_point(event.position):
			_score_and_move()

func _score_and_move() -> void:
	emit_signal("tapped")
	move_to_random_position()

func move_to_random_position() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	var max_x: int = max(int(screen_size.x - size.x), 0)
	var max_y: int = max(int(screen_size.y - size.y), 0)
	position = Vector2(rng.randi_range(0, max_x), rng.randi_range(0, max_y))
