extends Node
class_name GameManager

## GameManager - Handles game state, scoring, and persistence

signal score_changed(new_score: int)
signal best_score_changed(new_best: int)
signal game_over(final_score: int, is_new_best: bool)

var current_score: int = 0
var best_score: int = 0
var is_game_active: bool = false
var difficulty_level: float = 1.0

const STORAGE_FILE = "user://save_data.json"
const BASE_OBSTACLE_SPEED = 300.0
const BASE_SPAWN_INTERVAL = 1.5
const MAX_DIFFICULTY = 3.0
const DIFFICULTY_INCREASE_RATE = 0.05

func _ready() -> void:
	load_best_score()

func load_best_score() -> void:
	var file = FileAccess.open(STORAGE_FILE, FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if data.get("best_score"):
			best_score = data["best_score"]
			best_score_changed.emit(best_score)
		file.close()

func save_best_score() -> void:
	var file = FileAccess.open(STORAGE_FILE, FileAccess.WRITE)
	if file:
		var data = {"best_score": best_score}
		file.store_string(JSON.stringify(data))
		file.close()

func start_game() -> void:
	current_score = 0
	difficulty_level = 1.0
	is_game_active = true
	score_changed.emit(current_score)

func add_score(points: int = 1) -> void:
	if not is_game_active:
		return
	current_score += points
	score_changed.emit(current_score)
	
	# Increase difficulty gradually
	difficulty_level = min(difficulty_level + DIFFICULTY_INCREASE_RATE, MAX_DIFFICULTY)

func end_game() -> void:
	is_game_active = false
	var is_new_best = false
	if current_score > best_score:
		best_score = current_score
		best_score_changed.emit(best_score)
		save_best_score()
		is_new_best = true
	game_over.emit(current_score, is_new_best)

func get_obstacle_speed() -> float:
	return BASE_OBSTACLE_SPEED * difficulty_level

func get_spawn_interval() -> float:
	return BASE_SPAWN_INTERVAL / difficulty_level

func reset_game() -> void:
	current_score = 0
	difficulty_level = 1.0
	is_game_active = false
	score_changed.emit(0)