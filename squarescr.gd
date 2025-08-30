extends ColorRect

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_STOP  # let the control accept mouse-style input
	if size == Vector2.ZERO:
		size = Vector2(100, 100)
	move_to_random_position()

# Mouse/desktop clicks (and touch if "Emulate Mouse From Touch" is ON)
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		move_to_random_position()

# Real Android touch events (works even if emulation is OFF)
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if get_global_rect().has_point(event.position):
			move_to_random_position()

func move_to_random_position() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	var max_x: int = max(int(screen_size.x - size.x), 0)
	var max_y: int = max(int(screen_size.y - size.y), 0)
	position = Vector2(rng.randi_range(0, max_x), rng.randi_range(0, max_y))
