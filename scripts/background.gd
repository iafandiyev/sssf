extends Node2D

## Background - Animated background with parallax layers

@onready var layer1 = $Layer1
@onready var layer2 = $Layer2
@onready var layer3 = $Layer3
@onready var ground = $Ground

var ambient_tween: Tween
var game_tween: Tween
var time_accumulator: float = 0.0

@onready var game_manager = get_node("/root/GameManager")

func _ready() -> void:
	_setup_layers()
	start_ambient_animation()

func _setup_layers() -> void:
	# Layer 1 - Far background (slowest)
	_create_gradient_layer(layer1, Color(0.12, 0.12, 0.14, 1.0), Color(0.18, 0.15, 0.2, 1.0))
	
	# Layer 2 - Mid background shapes
	_create_shape_layer(layer2)
	
	# Layer 3 - Near background particles (disabled for compatibility)
	# _create_particle_layer(layer3)
	
	# Ground
	_create_ground()

func _create_gradient_layer(node: Node2D, color_top: Color, color_bottom: Color) -> void:
	var rect = Polygon2D.new()
	var viewport = get_viewport()
	var size = viewport.get_visible_rect().size
	rect.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(size.x, 0),
		Vector2(size.x, size.y),
		Vector2(0, size.y)
	])
	rect.z_index = -10
	node.add_child(rect)
	
	# Use a simple color modulation instead of shader for compatibility
	rect.color = color_top.lerp(color_bottom, 0.5)

func _create_shape_layer(node: Node2D) -> void:
	# Create floating geometric shapes
	for i in range(8):
		var shape_type = randi() % 3
		var shape_node = Node2D.new()
		shape_node.z_index = -5
		node.add_child(shape_node)
		
		var x = randf_range(0, get_viewport().get_visible_rect().size.x)
		var y = randf_range(0, get_viewport().get_visible_rect().size.y)
		shape_node.position = Vector2(x, y)
		
		var size = randf_range(30.0, 80.0)
		var color = Color(
			randf_range(0.2, 0.5),
			randf_range(0.3, 0.6),
			randf_range(0.5, 0.8),
			randf_range(0.05, 0.15)
		)
		
		match shape_type:
			0: _add_circle(shape_node, size, color)
			1: _add_rectangle(shape_node, size, color)
			2: _add_triangle(shape_node, size, color)
		
		# Add floating animation
		var tween = shape_node.create_tween()
		tween.set_loops()
		var float_y = randf_range(20.0, 50.0)
		var float_time = randf_range(4.0, 8.0)
		tween.tween_property(shape_node, "position:y", y + float_y, float_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(shape_node, "position:y", y, float_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		# Rotation
		var rot_tween = shape_node.create_tween()
		rot_tween.set_loops()
		var rot_dir = 1.0 if randf() > 0.5 else -1.0
		rot_tween.tween_property(shape_node, "rotation", rot_dir * TAU, randf_range(10.0, 20.0)).set_trans(Tween.TRANS_LINEAR)

func _add_circle(parent: Node2D, size: float, color: Color) -> void:
	var poly = Polygon2D.new()
	poly.polygon = _create_circle_polygon(size, 16)
	poly.color = color
	parent.add_child(poly)

func _add_rectangle(parent: Node2D, size: float, color: Color) -> void:
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(-size/2, -size/2),
		Vector2(size/2, -size/2),
		Vector2(size/2, size/2),
		Vector2(-size/2, size/2)
	])
	poly.color = color
	parent.add_child(poly)

func _add_triangle(parent: Node2D, size: float, color: Color) -> void:
	var poly = Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(0, -size),
		Vector2(size * 0.866, size * 0.5),
		Vector2(-size * 0.866, size * 0.5)
	])
	poly.color = color
	parent.add_child(poly)

func _create_circle_polygon(radius: float, segments: int) -> PackedVector2Array:
	var points = PackedVector2Array()
	for i in range(segments):
		var angle = (i / segments) * TAU
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	return points

func _create_particle_layer(node: Node2D) -> void:
	var particles = GPUParticles2D.new()
	particles.amount = 30
	particles.lifetime = 10.0
	particles.one_shot = false
	particles.explosiveness = 0.0
	particles.speed_scale = 0.1
	particles.z_index = -3
	node.add_child(particles)
	
	var proc = ParticleProcessMaterial.new()
	proc.color = Color(0.4, 0.6, 0.9, 0.3)
	var grad = Gradient.new()
	grad.set_colors(PackedColorArray([
		Color(0.3, 0.5, 0.8, 0.0),
		Color(0.4, 0.6, 0.9, 0.2),
		Color(0.3, 0.5, 0.8, 0.0)
	]))
	proc.color_ramp = grad
	proc.scale = Vector2(0.5, 0.5)
	proc.spread = 45
	particles.process_material = proc
	
	var viewport = get_viewport()
	var rect_size = viewport.get_visible_rect().size * 1.5
	# Skip emission shape for compatibility

func _create_ground() -> void:
	var viewport = get_viewport()
	var width = viewport.get_visible_rect().size.x
	var height = 80.0
	
	var rect = Polygon2D.new()
	rect.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(width * 2, 0),
		Vector2(width * 2, height),
		Vector2(0, height)
	])
	rect.position = Vector2(0, viewport.get_visible_rect().size.y - height/2)
	rect.z_index = -1
	ground.add_child(rect)
	
	# Simple dark ground color
	rect.color = Color(0.1, 0.1, 0.12, 1.0)

func start_ambient_animation() -> void:
	if ambient_tween:
		ambient_tween.kill()
	ambient_tween = create_tween()
	ambient_tween.set_loops()
	ambient_tween.tween_callback(_shift_colors.bind()).set_delay(5.0)

func _shift_colors() -> void:
	# Subtle color shifts for ambient feel
	pass

func start_game_animation() -> void:
	if game_tween:
		game_tween.kill()
	game_tween = create_tween()
	# Slightly faster particle movement during game
	for child in layer3.get_children():
		if child is GPUParticles2D:
			var proc = child.process_material
			if proc:
				game_tween.tween_property(proc, "direction:y", -1.5, 0.5)
	
	game_tween.tween_callback(_start_ground_scroll.bind())

func _start_ground_scroll() -> void:
	# Ground scrolling handled in _process
	pass

func _process(delta: float) -> void:
	if not game_manager.is_game_active:
		return
	
	time_accumulator += delta
	
	# Parallax scrolling
	var speed = game_manager.get_obstacle_speed()
	layer2.position.x = -speed * time_accumulator * 0.1
	layer3.position.x = -speed * time_accumulator * 0.2
	
	# Wrap around
	var viewport = get_viewport()
	var width = viewport.get_visible_rect().size.x
	if layer2.position.x < -width:
		layer2.position.x += width * 2
	if layer3.position.x < -width:
		layer3.position.x += width * 2