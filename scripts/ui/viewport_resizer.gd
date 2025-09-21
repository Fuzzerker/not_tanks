extends Control

# Script to handle dynamic viewport resizing
# This ensures the game content scales properly when the window is resized

func _ready():
	# Connect to the viewport size changed signal
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	# Set initial size
	_update_size()

func _on_viewport_size_changed():
	_update_size()

func _update_size():
	# Get the current viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Ensure we have valid dimensions
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		return
	
	# Update our control size to match the viewport
	custom_minimum_size = viewport_size
	size = viewport_size
	
	# Update anchors to fill the entire viewport
	anchors_preset = Control.PRESET_FULL_RECT
	
	# Ensure the game world (TileMapLayer) scales with the viewport
	var tilemap = get_node("TileMapLayer")
	if tilemap and is_instance_valid(tilemap):
		# The TileMapLayer will automatically scale with the viewport
		# due to the canvas_items stretch mode
		# Force a redraw to ensure proper scaling
		tilemap.update()
	
	# Update camera to handle the new viewport size
	var camera = get_node("Camera2D")
	if camera and is_instance_valid(camera):
		# The camera will automatically adjust to the new viewport size
		# Update camera limits based on new viewport size
		var aspect_ratio = viewport_size.x / viewport_size.y
		if aspect_ratio > 1.5:  # Wide screen
			# Adjust camera limits for wide screens
			pass
		elif aspect_ratio < 0.8:  # Tall screen
			# Adjust camera limits for tall screens
			pass
