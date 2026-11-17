extends Node

## ObstacleSpawner - Manages spawning of obstacles with increasing difficulty

@onready var game_manager = get_node("/root/GameManager")

var obstacle_script = preload("res://scripts/obstacle.gd")
var spawn_timer: Timer

func _ready() -> void:
	_setup_timer()

func _setup_timer() -> void:
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timeout.bind())
	add_child(spawn_timer)
	_schedule_next_spawn()

func _schedule_next_spawn() -> void:
	if not game_manager.is_game_active:
		return
	
	var interval = game_manager.get_spawn_interval()
	# Add some randomness
	interval *= randf_range(0.8, 1.2)
	spawn_timer.wait_time = interval
	spawn_timer.start()

func _on_spawn_timeout() -> void:
	if not game_manager.is_game_active:
		return
	
	_spawn_obstacle()
	_schedule_next_spawn()

func _spawn_obstacle() -> void:
	var viewport = get_viewport()
	var screen_width = viewport.get_visible_rect().size.x
	var screen_height = viewport.get_visible_rect().size.y
	
	var obstacle_type = _pick_obstacle_type()
	
	match obstacle_type:
		0: _spawn_top_bottom_pair(screen_width, screen_height)
		1: _spawn_single_middle(screen_width, screen_height)
		2: _spawn_double_gap(screen_width, screen_height)

func _pick_obstacle_type() -> int:
	# Higher difficulty = more complex obstacles
	var diff = game_manager.difficulty_level
	if diff < 1.3:
		return 0
	elif diff < 1.8:
		return randi() % 2
	else:
		return randi() % 3

func _spawn_top_bottom_pair(screen_width: float, screen_height: float) -> void:
	var gap_size = 180.0 / game_manager.difficulty_level
	gap_size = clamp(gap_size, 140.0, 200.0)
	
	var top_height = randf_range(100.0, screen_height - gap_size - 100.0)
	var bottom_y = top_height + gap_size
	var bottom_height = screen_height - bottom_y
	
	# Top obstacle
	var top_obs = obstacle_script.new()
	top_obs.position = Vector2(screen_width + 50, top_height / 2.0)
	top_obs.height = top_height
	top_obs.set_speed(game_manager.get_obstacle_speed())
	add_child(top_obs)
	
	# Bottom obstacle
	var bottom_obs = obstacle_script.new()
	bottom_obs.position = Vector2(screen_width + 50, bottom_y + bottom_height / 2.0)
	bottom_obs.height = bottom_height
	bottom_obs.set_speed(game_manager.get_obstacle_speed())
	add_child(bottom_obs)

func _spawn_single_middle(screen_width: float, screen_height: float) -> void:
	var height = randf_range(150.0, 250.0)
	var y_pos = randf_range(height / 2.0 + 50.0, screen_height - height / 2.0 - 50.0)
	
	var obs = obstacle_script.new()
	obs.position = Vector2(screen_width + 50, y_pos)
	obs.height = height
	obs.set_speed(game_manager.get_obstacle_speed())
	add_child(obs)

func _spawn_double_gap(screen_width: float, screen_height: float) -> void:
	var gap_size = 150.0 / game_manager.difficulty_level
	gap_size = clamp(gap_size, 110.0, 160.0)
	
	var top_height = randf_range(80.0, (screen_height - 2.0 * gap_size) / 2.0)
	var middle_y = top_height + gap_size
	var middle_height = randf_range(80.0, 150.0)
	var bottom_y = middle_y + middle_height + gap_size
	var bottom_height = screen_height - bottom_y
	
	# Top
	var top_obs = obstacle_script.new()
	top_obs.position = Vector2(screen_width + 50, top_height / 2.0)
	top_obs.height = top_height
	top_obs.set_speed(game_manager.get_obstacle_speed())
	add_child(top_obs)
	
	# Middle
	var mid_obs = obstacle_script.new()
	mid_obs.position = Vector2(screen_width + 50, middle_y + middle_height / 2.0)
	mid_obs.height = middle_height
	mid_obs.set_speed(game_manager.get_obstacle_speed())
	add_child(mid_obs)
	
	# Bottom
	var bot_obs = obstacle_script.new()
	bot_obs.position = Vector2(screen_width + 50, bottom_y + bottom_height / 2.0)
	bot_obs.height = bottom_height
	bot_obs.set_speed(game_manager.get_obstacle_speed())
	add_child(bot_obs)

func clear_all() -> void:
	for child in get_children():
		if child.get_script() == obstacle_script:
			child.queue_free()
	spawn_timer.stop()