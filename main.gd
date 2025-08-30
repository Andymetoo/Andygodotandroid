extends Node2D

@onready var score_label: Label = $UI/ScoreLabel

# ——— Tuning ———
@export var square_scene: PackedScene                   # assign res://Square.tscn in Inspector
@export var spawn_base_interval: float = 1.2            # seconds at start
@export var spawn_min_interval: float = 0.35            # fastest spawn
@export var difficulty_ramp_time: float = 60.0          # reach min interval by this time
@export var square_shrink_duration: float = 2.0         # each square shrinks to 0 in this time
@export var square_start_scale: float = 1.5

var _elapsed: float = 0.0
var _running: bool = true
var _score: int = 0
var _viewport_size: Vector2

func _ready() -> void:
	_viewport_size = get_viewport_rect().size
	if square_scene == null:
		# Fallback in case you forget to set it in the Inspector
		square_scene = load("res://Square.tscn")
	_update_score(false)
	spawn_loop()

func _process(delta: float) -> void:
	if _running:
		_elapsed += delta

func spawn_loop() -> void:
	spawn_one()
	if _running:
		var wait: float = _current_interval()
		var timer: SceneTreeTimer = get_tree().create_timer(wait)
		timer.timeout.connect(spawn_loop)

func _current_interval() -> float:
	var t: float = clamp(_elapsed / difficulty_ramp_time, 0.0, 1.0)
	return lerpf(spawn_base_interval, spawn_min_interval, t)

func spawn_one() -> void:
	if not _running or square_scene == null:
		return

	var sq: Node = square_scene.instantiate()  # works whether root is Control or Node2D
	add_child(sq)

	# Pass settings to the square (these are @export vars on the square script)
	sq.set("shrink_duration", square_shrink_duration)
	sq.set("start_scale", square_start_scale)

	# Place fully on-screen even at start_scale (assumes 100x100 base size)
	var base_size: Vector2 = Vector2(100.0, 100.0)
	var half: Vector2 = base_size * (square_start_scale * 0.5)
	var x_min: float = half.x
	var x_max: float = max(_viewport_size.x - half.x, x_min)
	var y_min: float = half.y
	var y_max: float = max(_viewport_size.y - half.y, y_min)
	var px: float = randf_range(x_min, x_max)
	var py: float = randf_range(y_min, y_max)
	var pos: Vector2 = Vector2(px, py)

	# Set position depending on root type
	if sq is Node2D:
		(sq as Node2D).position = pos
	elif sq is Control:
		(sq as Control).position = pos
	else:
		sq.set("position", pos)  # fallback

	# Connect signals (both Control/Node2D are Nodes, so this is fine)
	sq.connect("cleared", Callable(self, "_on_square_cleared"))
	sq.connect("expired", Callable(self, "_on_square_expired"))

func _on_square_cleared() -> void:
	if not _running:
		return
	_score += 1
	_update_score(false)

func _on_square_expired() -> void:
	if not _running:
		return
	_running = false
	_update_score(true)

	# Simple game-over label
	var over: Label = Label.new()
	over.text = "GAME OVER\nScore: %d" % _score
	over.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	over.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	over.add_theme_font_size_override("font_size", 48)
	add_child(over)
	over.global_position = _viewport_size * 0.5

func _update_score(game_over: bool) -> void:
	if game_over:
		score_label.text = "Score: %d  (Game Over)" % _score
	else:
		score_label.text = "Score: %d" % _score
