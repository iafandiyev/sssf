extends Node2D

## Main - Main game scene controller

@onready var game_manager = get_node("/root/GameManager")
@onready var audio_manager = get_node("/root/AudioManager")

@onready var player = $Player
@onready var obstacle_spawner = $ObstacleSpawner
@onready var background = $Background

var ui_layer: CanvasLayer
var start_screen: Control
var game_hud: Control
var game_over_screen: Control
var start_best_label: Label
var start_button: Button
var score_label: Label
var go_final_score: Label
var go_best_score: Label
var go_new_best: Label
var go_restart_button: Button

func _ready() -> void:
	_create_ui()
	_connect_signals()
	_show_start_screen()

func _create_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	# Start Screen
	start_screen = Control.new()
	start_screen.anchors_preset = Control.PRESET_FULL_RECT
	ui_layer.add_child(start_screen)
	
	var start_vbox = VBoxContainer.new()
	start_vbox.anchors_preset = Control.PRESET_FULL_RECT
	start_vbox.offset_left = 40
	start_vbox.offset_top = 100
	start_vbox.offset_right = 40
	start_vbox.offset_bottom = 100
	start_screen.add_child(start_vbox)
	
	var title = Label.new()
	title.text = "MINI JUMP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(0.98, 0.95, 0.9, 1))
	title.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12, 1))
	title.add_theme_constant_override("font_outline_size", 2)
	start_vbox.add_child(title)
	
	start_best_label = Label.new()
	start_best_label.text = "BEST: 0"
	start_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_best_label.add_theme_font_size_override("font_size", 24)
	start_best_label.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6, 1))
	start_vbox.add_child(start_best_label)
	
	# Add spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 20)
	start_vbox.add_child(spacer1)
	
	start_button = Button.new()
	start_button.text = "TAP TO START"
	start_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_button.add_theme_font_size_override("font_size", 28)
	start_button.custom_minimum_size = Vector2(0, 60)
	start_vbox.add_child(start_button)
	
	# Add spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 30)
	start_vbox.add_child(spacer2)
	
	var hint = Label.new()
	hint.text = "Tap anywhere to jump\nAvoid obstacles"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4, 1))
	start_vbox.add_child(hint)
	
	# Game HUD
	game_hud = Control.new()
	game_hud.anchors_preset = Control.PRESET_FULL_RECT
	game_hud.visible = false
	ui_layer.add_child(game_hud)
	
	score_label = Label.new()
	score_label.anchors_preset = Control.PRESET_TOP_WIDE
	score_label.offset_left = 20
	score_label.offset_top = 20
	score_label.offset_right = 20
	score_label.offset_bottom = 80
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.add_theme_font_size_override("font_size", 72)
	score_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	score_label.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12, 1))
	score_label.add_theme_constant_override("font_outline_size", 3)
	score_label.text = "0"
	game_hud.add_child(score_label)
	
	# Game Over Screen
	game_over_screen = Control.new()
	game_over_screen.anchors_preset = Control.PRESET_FULL_RECT
	game_over_screen.visible = false
	ui_layer.add_child(game_over_screen)
	
	var go_vbox = VBoxContainer.new()
	go_vbox.anchors_preset = Control.PRESET_FULL_RECT
	go_vbox.offset_left = 40
	go_vbox.offset_top = 100
	go_vbox.offset_right = 40
	go_vbox.offset_bottom = 100
	game_over_screen.add_child(go_vbox)
	
	var go_title = Label.new()
	go_title.text = "GAME OVER"
	go_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_title.add_theme_font_size_override("font_size", 48)
	go_title.add_theme_color_override("font_color", Color(0.98, 0.95, 0.9, 1))
	go_title.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12, 1))
	go_title.add_theme_constant_override("font_outline_size", 2)
	go_vbox.add_child(go_title)
	
	go_final_score = Label.new()
	go_final_score.text = "SCORE: 0"
	go_final_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_final_score.add_theme_font_size_override("font_size", 36)
	go_final_score.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6, 1))
	go_vbox.add_child(go_final_score)
	
	go_best_score = Label.new()
	go_best_score.text = "BEST: 0"
	go_best_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_best_score.add_theme_font_size_override("font_size", 24)
	go_best_score.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6, 1))
	go_vbox.add_child(go_best_score)
	
	go_new_best = Label.new()
	go_new_best.text = "NEW BEST!"
	go_new_best.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_new_best.add_theme_font_size_override("font_size", 28)
	go_new_best.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	go_new_best.add_theme_color_override("font_outline_color", Color(0.8, 0.5, 0.1, 1))
	go_new_best.add_theme_constant_override("font_outline_size", 2)
	go_new_best.visible = false
	go_vbox.add_child(go_new_best)
	
	# Add spacer
	var spacer3 = Control.new()
	spacer3.custom_minimum_size = Vector2(0, 40)
	go_vbox.add_child(spacer3)
	
	go_restart_button = Button.new()
	go_restart_button.text = "PLAY AGAIN"
	go_restart_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_restart_button.add_theme_font_size_override("font_size", 28)
	go_restart_button.custom_minimum_size = Vector2(0, 60)
	go_vbox.add_child(go_restart_button)

func _connect_signals() -> void:
	game_manager.score_changed.connect(_on_score_changed)
	game_manager.best_score_changed.connect(_on_best_score_changed)
	game_manager.game_over.connect(_on_game_over)
	start_button.pressed.connect(_on_start_pressed)
	go_restart_button.pressed.connect(_on_restart_pressed)

func _on_score_changed(score: int) -> void:
	score_label.text = str(score)
	# Pop animation
	var tween = create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _on_best_score_changed(best: int) -> void:
	start_best_label.text = "BEST: %d" % best
	go_best_score.text = "BEST: %d" % best

func _on_game_over(final_score: int, is_new_best: bool) -> void:
	obstacle_spawner.clear_all()
	player.die()
	_show_game_over(final_score, is_new_best, game_manager.best_score)

func _on_start_pressed() -> void:
	audio_manager.play_click()
	_start_game()

func _on_restart_pressed() -> void:
	audio_manager.play_click()
	_restart_game()

func _show_start_screen() -> void:
	start_best_label.text = "BEST: %d" % game_manager.best_score
	start_screen.visible = true
	game_hud.visible = false
	game_over_screen.visible = false
	
	# Animate in
	start_screen.modulate = Color(1, 1, 1, 0)
	start_screen.position = Vector2(0, 50)
	var tween = create_tween()
	tween.tween_property(start_screen, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(start_screen, "position:y", 0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	background.start_ambient_animation()

func _start_game() -> void:
	_hide_start_screen()
	game_manager.start_game()
	player.reset_position()
	obstacle_spawner._schedule_next_spawn()
	background.start_game_animation()

func _hide_start_screen() -> void:
	var tween = create_tween()
	tween.tween_property(start_screen, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_on_start_hidden.bind())

func _on_start_hidden() -> void:
	start_screen.visible = false
	game_hud.visible = true
	game_hud.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(game_hud, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _show_game_over(final_score: int, is_new_best: bool, best_score: int) -> void:
	game_hud.visible = false
	game_over_screen.visible = true
	game_over_screen.modulate = Color(1, 1, 1, 0)
	
	go_final_score.text = "SCORE: %d" % final_score
	go_best_score.text = "BEST: %d" % best_score
	go_new_best.visible = is_new_best
	
	if is_new_best:
		go_new_best.modulate = Color(1, 1, 1, 0)
		var tween = create_tween()
		tween.tween_property(go_new_best, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(go_new_best, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_delay(0.5)
		tween.tween_property(go_new_best, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_delay(1.0)
		tween.set_loops()
	
	var tween = create_tween()
	tween.tween_property(game_over_screen, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	game_over_screen.position = Vector2(0, 50)
	tween.parallel().tween_property(game_over_screen, "position:y", 0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _restart_game() -> void:
	_hide_game_over()
	game_manager.reset_game()
	# Now start a new game
	game_manager.start_game()
	player.reset_position()
	obstacle_spawner.clear_all()
	obstacle_spawner._schedule_next_spawn()
	background.start_game_animation()

func _hide_game_over() -> void:
	var tween = create_tween()
	tween.tween_property(game_over_screen, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_on_game_over_hidden.bind())

func _on_game_over_hidden() -> void:
	game_over_screen.visible = false