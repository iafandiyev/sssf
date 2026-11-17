extends Area2D
class_name Obstacle

## Obstacle - Simple rectangle obstacles that move from right to left

@export var width: float = 40.0
@export var height: float = 120.0

var mesh_instance: Polygon2D
var collision_shape: CollisionShape2D
var scored: bool = false
var obstacle_speed: float = 300.0

@onready var game_manager = get_node("/root/GameManager")

func _ready() -> void:
	_setup_visuals()
	_setup_physics()

func _setup_visuals() -> void:
	mesh_instance = Polygon2D.new()
	mesh_instance.polygon = PackedVector2Array([
		Vector2(-width/2, -height/2),
		Vector2(width/2, -height/2),
		Vector2(width/2, height/2),
		Vector2(-width/2, height/2)
	])
	mesh_instance.z_index = 5
	mesh_instance.color = Color(0.25, 0.65, 0.95, 1.0)
	add_child(mesh_instance)
	
	# Add gradient effect using a shader
	var material = CanvasItemMaterial.new()
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;
	uniform vec4 color_top : source_color = vec4(0.25, 0.65, 0.95, 1.0);
	uniform vec4 color_bottom : source_color = vec4(0.15, 0.45, 0.75, 1.0);
	void fragment() {
		COLOR = mix(color_bottom, color_top, (UV.y + 1.0) * 0.5) * TEXTURE_COLOR;
	}
	"""
	material.shader = shader
	material.set_shader_parameter("color_top", Color(0.25, 0.65, 0.95, 1.0))
	material.set_shader_parameter("color_bottom", Color(0.15, 0.45, 0.75, 1.0))
	mesh_instance.material = material

func _setup_physics() -> void:
	collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(width, height)
	collision_shape.shape = rect_shape
	add_child(collision_shape)
	
	collision_layer = 2
	collision_mask = 1
	
	body_entered.connect(_on_body_entered.bind())
	area_entered.connect(_on_area_entered.bind())

func set_speed(speed: float) -> void:
	obstacle_speed = speed

func _physics_process(delta: float) -> void:
	if not game_manager.is_game_active:
		return
	
	position.x -= obstacle_speed * delta
	
	# Check if player passed this obstacle (for scoring)
	if not scored and position.x < 50.0:  # Player is at x=100
		scored = true
		game_manager.add_score(1)
		get_node("/root/AudioManager").play_score()
	
	# Remove obstacle when off screen
	if position.x < -100.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and game_manager.is_game_active:
		game_manager.end_game()
		get_node("/root/AudioManager").play_game_over()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and game_manager.is_game_active:
		game_manager.end_game()
		get_node("/root/AudioManager").play_game_over()