extends Node2D

@export var pivot: Node2D
@export var icon: Node2D
@export var angle_offset = 90

func _process(_delta):
	var canvas_transform = get_canvas_transform()
	var top_left = -canvas_transform.origin / canvas_transform.get_scale()
	var size = get_viewport_rect().size / canvas_transform.get_scale()
	
	update_finder_position(Rect2(top_left, size))
	update_finder_rotation()

func update_finder_position(bounds):
	pivot.global_position.x = clamp(global_position.x, bounds.position.x, bounds.end.x)
	pivot.global_position.y = clamp(global_position.y, bounds.position.y, bounds.end.y)

func update_finder_rotation():
	var angle = (global_position - pivot.global_position).angle()
	pivot.global_rotation = angle + deg_to_rad(angle_offset)
	icon.global_rotation = 0
