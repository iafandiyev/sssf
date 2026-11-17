extends Node

## Generate app icons programmatically

func _ready() -> void:
	generate_all_icons()
	get_tree().quit()

func generate_all_icons() -> void:
	var sizes = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024]
	
	for size in sizes:
		var img = _create_icon(size)
		var path = "res://icon_%d.png" % size
		var err = img.save_png(path)
		if err != OK:
			printerr("Failed to save icon %d: %s" % [size, err])
		else:
			print("Generated icon_%d.png" % size)
	
	print("All icons generated!")

func _create_icon(size: int) -> Image:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	# Background gradient
	var center = Vector2(size / 2.0, size / 2.0)
	var max_dist = size * 0.707
	
	for y in range(size):
		for x in range(size):
			var pos = Vector2(x, y)
			var dist = pos.distance_to(center) / max_dist
			dist = clamp(dist, 0.0, 1.0)
			
			# Dark background gradient
			var bg_color = Color(
				lerp(0.18, 0.12, dist),
				lerp(0.15, 0.12, dist),
				lerp(0.2, 0.14, dist),
				1.0
			)
			img.set_pixel(x, y, bg_color)
	
	# Draw ball
	var ball_radius = size * 0.35
	var ball_center = center
	
	for y in range(size):
		for x in range(size):
			var pos = Vector2(x, y)
			var dist = pos.distance_to(ball_center)
			
			if dist < ball_radius:
				var norm_dist = dist / ball_radius
				# Ball gradient - coral/pink
				var ball_color = Color(
					lerp(1.0, 0.95, norm_dist),
					lerp(0.45, 0.6, norm_dist),
					lerp(0.55, 0.7, norm_dist),
					1.0
				)
				img.set_pixel(x, y, ball_color)
			
			# Glow ring
			elif dist < ball_radius * 1.15:
				var glow_intensity = 1.0 - (dist - ball_radius) / (ball_radius * 0.15)
				var glow_color = Color(1.0, 0.4, 0.5, glow_intensity * 0.3)
				var existing = img.get_pixel(x, y)
				img.set_pixel(x, y, existing.lerp(glow_color, glow_intensity * 0.5))
	
	# Add subtle highlight on ball
	var highlight_radius = ball_radius * 0.3
	var highlight_center = ball_center + Vector2(-ball_radius * 0.3, -ball_radius * 0.3)
	
	for y in range(size):
		for x in range(size):
			var pos = Vector2(x, y)
			var dist = pos.distance_to(highlight_center)
			
			if dist < highlight_radius:
				var norm_dist = dist / highlight_radius
				var highlight = Color(1.0, 0.8, 0.85, (1.0 - norm_dist) * 0.4)
				var existing = img.get_pixel(x, y)
				img.set_pixel(x, y, existing.lerp(highlight, (1.0 - norm_dist) * 0.5))
	
	return img