extends CharacterBody2D
class_name Player

## Player - The jumping ball character

@export var jump_force: float = -450.0
@export var gravity: float = 1200.0
@export var max_fall_speed: float = 800.0
@export var ground_y: float = 700.0

var is_grounded: bool = true
var trail_particles: GPUParticles2D
var mesh_instance: Polygon2D
var collision_shape: CollisionShape2D
var squash_tween: Tween
var ball_radius: float = 24.0

@onready var game_manager = get_node("/root/GameManager")
@onready var audio_manager = get_node("/root/AudioManager")

func _ready() -> void:
	_setup_visuals()
	_setup_physics()
	_setup_input()

func _setup_visuals() -> void:
	# Create ball using Polygon2D (circle approximation)
	mesh_instance = Polygon2D.new()
	mesh_instance.polygon = _create_circle_polygon(ball_radius, 32)
	mesh_instance.z_index = 10
	mesh_instance.color = Color(1.0, 0.5, 0.6, 1.0)
	add_child(mesh_instance)
	
	# Add glow effect
	var glow = Polygon2D.new()
	glow.polygon = _create_circle_polygon(ball_radius + 4, 32)
	glow.z_index = 9
	glow.color = Color(1.0, 0.4, 0.5, 0.15)
	add_child(glow)
	
	# Trail particles
	trail_particles = GPUParticles2D.new()
	trail_particles.amount = 15
	trail_particles.lifetime = 0.3
	trail_particles.one_shot = false
	trail_particles.explosiveness = 0.0
	trail_particles.speed_scale = 0.5
	trail_particles.z_index = 8
	add_child(trail_particles)
	
	var particle_process = ParticleProcessMaterial.new()
	particle_process.color = Color(1.0, 0.5, 0.6, 0.6)
	particle_process.color_ramp = Gradient.new()
	var gradient = Gradient.new()
	var colors = PackedColorArray([Color(1.0, 0.4, 0.5, 0.5), Color(1.0, 0.6, 0.7, 0.0)])
	gradient.set_colors(colors)
	particle_process.color_ramp = gradient
	particle_process.scale = Vector2(0.3, 0.3)
	var scale_curve = Curve.new()
	scale_curve.add_point(Vector2(0.0, 1.0))
	scale_curve.add_point(Vector2(1.0, 0.0))
	particle_process.scale_curve = scale_curve
	trail_particles.process_material = particle_process
	trail_particles.emitting = false

func _create_circle_polygon(radius: float, segments: int) -> PackedVector2Array:
	var points = PackedVector2Array()
	for i in range(segments):
		var angle = (i / segments) * TAU
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	return points

func _setup_physics() -> void:
	collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 22.0
	collision_shape.shape = circle_shape
	add_child(collision_shape)
	
	collision_layer = 1
	collision_mask = 2

func _setup_input() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if not game_manager.is_game_active:
		velocity = Vector2.ZERO
		return
	
	# Apply gravity
	velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
	
	# Check ground collision
	if position.y >= ground_y:
		position.y = ground_y
		velocity.y = 0.0
		if not is_grounded:
			is_grounded = true
			_on_land()
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if not game_manager.is_game_active:
		return
		
	if event is InputEventScreenTouch and event.pressed:
		_try_jump()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_jump()
	elif event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_UP or event.keycode == KEY_W):
		_try_jump()

func _try_jump() -> void:
	if is_grounded:
		velocity.y = jump_force
		is_grounded = false
		_on_jump()
		audio_manager.play_jump()
		trail_particles.emitting = true

func _on_jump() -> void:
	# Squash animation
	if squash_tween:
		squash_tween.kill()
	squash_tween = create_tween()
	squash_tween.set_parallel(true)
	squash_tween.tween_property(mesh_instance, "scale:y", 0.6, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	squash_tween.tween_property(mesh_instance, "scale:x", 1.4, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	squash_tween.tween_property(mesh_instance, "scale:y", 1.0, 0.15).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(0.08)
	squash_tween.tween_property(mesh_instance, "scale:x", 1.0, 0.15).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(0.08)

func _on_land() -> void:
	# Small bounce on land
	if squash_tween:
		squash_tween.kill()
	squash_tween = create_tween()
	squash_tween.set_parallel(true)
	squash_tween.tween_property(mesh_instance, "scale:y", 0.85, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	squash_tween.tween_property(mesh_instance, "scale:x", 1.15, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	squash_tween.tween_property(mesh_instance, "scale:y", 1.0, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(0.05)
	squash_tween.tween_property(mesh_instance, "scale:x", 1.0, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(0.05)
	trail_particles.emitting = false

func die() -> void:
	# Death animation
	if squash_tween:
		squash_tween.kill()
	squash_tween = create_tween()
	squash_tween.tween_property(mesh_instance, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	squash_tween.tween_property(mesh_instance, "scale", Vector2(0.1, 0.1), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	squash_tween.tween_callback(_on_death_animation_done.bind())

func _on_death_animation_done() -> void:
	queue_free()

func reset_position() -> void:
	position = Vector2(100.0, ground_y)
	velocity = Vector2.ZERO
	is_grounded = true
	mesh_instance.scale = Vector2(1.0, 1.0)
	mesh_instance.modulate = Color(1.0, 1.0, 1.0, 1.0)
	trail_particles.emitting = false
	show()