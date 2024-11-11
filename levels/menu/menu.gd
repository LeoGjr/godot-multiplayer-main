extends Node

@export var level_container: Node
@export var ui: Control
@export var leave_ui: Control
@export var ip_line_edit: LineEdit
@export var status_label: Label
@export var not_connected_hbox: HBoxContainer
@export var host_hbox: HBoxContainer

@export var level_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	#multiplayer.connection_failed.connect(_on_connection_failed)
	#multiplayer.connected_to_server.connect(_on_connected_to_server)
	
	multiplayer.peer_disconnected.connect(_on_lobby_left)
	LobbyHelper.lobby_webrtc_peers_ready.connect(_on_peers_ready)

func _on_host_button_pressed():
	not_connected_hbox.hide()
	host_hbox.show()
	MyLobby.create_game()
	status_label.text = "Hosting!"

func _on_join_button_pressed():
	not_connected_hbox.hide()
	MyLobby.join_game(ip_line_edit.text)
	status_label.text = "Connecting..."

func _on_start_button_pressed():
	LobbyHelper.lobby.state = LobbyHelper.LobbyState.SEALED
	LobbyHelper.lobby.save().async()

func change_level(scene):
	for c in level_container.get_children():
		level_container.remove_child(c)
		c.level_complete.disconnect(_on_level_complete)
		c.queue_free()
	var new_level = scene.instantiate()
	level_container.add_child(new_level)
	new_level.level_complete.connect(_on_level_complete)

func _on_connection_failed():
	status_label.text = "Failed to connect"
	not_connected_hbox.show()

func _on_connected_to_server():
	status_label.text = "Connected!"

func _on_peers_ready():
	if is_multiplayer_authority():
		hide_menu.rpc()
		change_level.call_deferred(level_scene)

@rpc("call_local", "authority", "reliable")
func hide_menu():
	ui.hide()
	leave_ui.show()

func _on_level_complete():
	call_deferred("change_level", level_scene)

func _on_leave_button_pressed():
	if is_multiplayer_authority():
		LobbyHelper.lobby.state = LobbyHelper.LobbyState.DONE
		LobbyHelper.lobby.save().async()
		for c in level_container.get_children():
			level_container.remove_child(c)
			c.level_complete.disconnect(_on_level_complete)
			c.queue_free()
	LobbyHelper._set_lobby(null)
	multiplayer.multiplayer_peer = null
	return_to_menu()

func _on_lobby_left(id):
	if id == 1:
		return_to_menu()

func return_to_menu():
	ui.show()
	not_connected_hbox.show()
	leave_ui.hide()
	host_hbox.hide()
	status_label.text = ""
