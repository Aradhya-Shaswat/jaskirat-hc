extends Control

var current_stage: int = 1 : set = set_current_stage
var stage_progress: float = 0.0 : set = set_stage_progress

var target_progress: float = 0.0

@export var color_start: Color = Color.GREEN
@export var color_mid: Color = Color.YELLOW
@export var color_end: Color = Color.RED

func set_current_stage(val: int) -> void:
	current_stage = val
	queue_redraw()

func set_stage_progress(val: float) -> void:
	target_progress = clamp(val, 0.0, 1.0)
	queue_redraw()

func _process(delta: float) -> void:
	if stage_progress != target_progress:
		stage_progress = lerp(stage_progress, target_progress, 5.0 * delta)
		if abs(stage_progress - target_progress) < 0.001:
			stage_progress = target_progress
		queue_redraw()

func _draw() -> void:
	var size_rect = get_size()
	var w = size_rect.x
	var h = size_rect.y
	var spacing = 4.0
	
	var num_rows = 5
	var block_w = (w - (num_rows - 1) * spacing) / float(num_rows)
	var block_h = (h - (num_rows - 1) * spacing) / float(num_rows)
	
	for r in range(num_rows):
		var blocks_in_row = r + 1
		var row_w = blocks_in_row * block_w + (blocks_in_row - 1) * spacing
		var start_x = (w - row_w) / 2.0
		var y = r * (block_h + spacing)
		
		# Define expected stage for this row (Row 0 = Stage 1, Row 4 = Stage 5)
		var row_stage = r + 1
		
		var depth_factor = float(r) / float(num_rows - 1)
		var row_color: Color
		if depth_factor < 0.5:
			row_color = color_start.lerp(color_mid, depth_factor * 2.0)
		else:
			row_color = color_mid.lerp(color_end, (depth_factor - 0.5) * 2.0)
			
		for c in range(blocks_in_row):
			var x = start_x + c * (block_w + spacing)
			var rect = Rect2(x, y, block_w, block_h)
			
			# Background block
			draw_rect(rect, Color(0.1, 0.1, 0.1, 0.5))
			
			var fill_alpha = 0.0
			
			# If this row represents a stage we've already beaten
			if current_stage > row_stage:
				fill_alpha = 1.0
			# If this row represents the current stage
			elif current_stage == row_stage:
				# Fill horizontally within the current row based on stage_progress
				var total_colored_blocks = stage_progress * blocks_in_row
				fill_alpha = clamp(total_colored_blocks - c, 0.0, 1.0)
				
			if fill_alpha > 0.0:
				var c_color = row_color
				c_color.a = fill_alpha
				draw_rect(rect, c_color)
