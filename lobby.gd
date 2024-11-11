extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const MAX_CONNECTIONS = 2

var players = {}

var player_info = {"name": "Name"}

var uuid := W4Utils.UUIDGenerator.new()

func _ready():
	#multiplayer.peer_connected.connect(_on_player_connected)
	#multiplayer.peer_disconnected.connect(_on_player_disconnected)
	#multiplayer.connected_to_server.connect(_on_connected_to_server)
	#multiplayer.connection_failed.connect(_on_connection_failed)
	#multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	LobbyHelper.lobby_created.connect(_on_lobby_created)
	LobbyHelper.lobby_joined.connect(_on_lobby_joined)
	
	var login_result = await W4GD.auth.login_device(uuid.generate_v4(), uuid.generate_v4()).async()
	
	if login_result.is_error():
		print(login_result.as_error().message)
	else:
		var user_info = await W4GD.auth.get_user().async()
		print("Logged In As: ", user_info.email)

func create_game():
	await LobbyHelper.create_lobby(LobbyHelper.LobbyType.WEBRTC)
	#players[1] = player_info
	#player_connected.emit(1, player_info)

func join_game(address):
	await LobbyHelper.join_lobby(address)
	#var peer = ENetMultiplayerPeer.new()
	#var error = peer.create_client(address, PORT)
	#if error:
		#return error
	#multiplayer.multiplayer_peer = peer

func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_to_server():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connection_failed():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

func _on_lobby_created(lobby):
	print("Created Lobby: ", lobby.id)
	DisplayServer.clipboard_set(lobby.id)
	lobby.player_joined.connect(_on_player_joined)

func _on_player_joined(id):
	print("Player joined!")

func _on_lobby_joined(lobby):
	print("Joined Lobby: ", lobby.id)
