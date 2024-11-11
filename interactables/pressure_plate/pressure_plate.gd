extends Node2D

signal toggle(state)

@export var is_down = false
@export var plate_up: Sprite2D
@export var plate_down: Sprite2D

var bodies_on_plate = 0

func _on_area_2d_body_entered(_body):
	if not multiplayer.is_server():
		return
	bodies_on_plate += 1
	update_plate_state()

func _on_area_2d_body_exited(_body):
	if multiplayer.multiplayer_peer == null:
		return
	if not multiplayer.is_server():
		return
	bodies_on_plate -= 1
	update_plate_state()

func update_plate_state():
	is_down = bodies_on_plate >= 1
	toggle.emit(is_down)
	set_plate_properties()

func set_plate_properties():
	plate_down.visible = is_down
	plate_up.visible = !is_down

func _on_multiplayer_synchronizer_delta_synchronized():
	set_plate_properties()
