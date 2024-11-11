extends Node2D

class_name KeyDoor

signal all_players_finished

@export var is_open = false
@export var door_open: Sprite2D
@export var door_closed: Sprite2D
@export var exit_area: Area2D

var finished_players = 0

func _on_area_2d_area_entered(area):
	if not multiplayer.is_server():
		return
	if is_open:
		return
	is_open = true
	exit_area.monitoring = true
	area.get_owner().queue_free()
	set_door_properties()

func set_door_properties():
	door_open.visible = is_open
	door_closed.visible = !is_open

func _on_multiplayer_synchronizer_delta_synchronized():
	set_door_properties()

func _on_exit_area_body_entered(body):
	body.queue_free()
	finished_players += 1
	if finished_players > len(multiplayer.get_peers()):
		all_players_finished.emit()
