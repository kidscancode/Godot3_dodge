extends Control

const DEFAULT_PORT = 8910 
const MAX_PEERS = 4

#vars
var players = {}
var player_name

#signals
signal player_list_change()
signal connection_established()

#when server sees client connect, load waiting area (server only)
func _player_connected(id):
	#_load_game()
	#get_node("Connect").hide()
	#get_node("Players").show()
	#emit_signal("player_list_change")
	pass
	
#when client connects, load waiting area (client only)
func on_connection_established(): 
	get_node("Connect").hide()
	get_node("Players").show()
	
func send_load_game():
	rpc("_load_game")
	
sync func _load_game():
	print("LOADING")
	var game = load("res://Main.tscn").instance()
	game.connect("game_finished",self,"_end_game",[],CONNECT_DEFERRED) 
	get_tree().get_root().add_child(game)

func refresh_lobby():
	var plist = players.values()
	plist.sort()
	get_node("Players/list").clear()
	get_node("Players/list").add_item(player_name + " (you)")
	#get_node("Players/list").add_item(
	for p in plist:
		get_node("Players/list").add_item(p)
	#for p_id in players:
		#get_node("Players/list").add_item(players[p_id])
		#print(players[p_id])
	get_node("Players/start").disabled = not get_tree().is_network_server()	

remote func register_player(id, new_player_name):
	if (get_tree().is_network_server()):
		# If we are the server, let everyone know about the new player
		rpc_id(id, "register_player", 1, player_name) # Send myself to new dude
		for p_id in players: # Then, for each remote player
			rpc_id(id, "register_player", p_id, players[p_id]) # Send player to new dude
			rpc_id(p_id, "register_player", id, new_player_name) # Send new dude to player
	players[id] = new_player_name
	emit_signal("player_list_change")
	#print("REGISTERED " + players[id])
	
func _player_disconnected(id):
	if (get_tree().is_network_server()):
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")

# callback from SceneTree, only for clients (not server)
func _connected_ok():
	rpc("register_player", get_tree().get_network_unique_id(), player_name)
	emit_signal("connection_established")
	print("Connection established")
	pass
	
	
# callback from SceneTree, only for clients (not server)	
func _connected_fail():

	_set_status("Couldn't connect",false)
	
	get_tree().set_network_peer(null) #remove peer
	
	get_node("Connect/join").set_disabled(false)
	get_node("Connect/host").set_disabled(false)

func _server_disconnected():
	_end_game("Server disconnected")
	
##### Game creation functions ######

func _end_game(with_error=""):
	if (has_node("/root/Main")):
		#erase game scene
		get_node("/root/Main").free() # erase immediately, otherwise network might show errors (this is why we connected deferred above)
		show()
	get_tree().set_network_peer(null) #remove peer
	
	get_node("Connect/join").set_disabled(false)
	get_node("Connect/host").set_disabled(false)
	
	_set_status(with_error,false)

func _set_status(text,isok):
	#simple way to show status		
	if (isok):
		get_node("Connect/status_ok").set_text(text)
		get_node("Connect/status_fail").set_text("")
	else:
		get_node("Connect/status_ok").set_text("")
		get_node("Connect/status_fail").set_text(text)

func _host(): 
	var host = NetworkedMultiplayerENet.new()
	player_name = get_node("Connect/nameLine").get_text()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(DEFAULT_PORT,MAX_PEERS) # max players = 1 + MAX_PEERS
	if (err!=OK):#check if address is being used already to host server
		_set_status("Can't host, address in use.",false)
		return
	get_tree().set_network_peer(host)
	get_node("Connect/join").set_disabled(true)
	get_node("Connect/host").set_disabled(true)
	get_node("Connect").hide()
	get_node("Players").show()
	_set_status("Waiting for player..",true)
	

func _join():
	var ip = get_node("Connect/addressLine").get_text()
	player_name = get_node("Connect/nameLine").get_text()
	if (not ip.is_valid_ip_address()):
		_set_status("IP address is invalid",false)
		return
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	host.create_client(ip,DEFAULT_PORT)
	get_tree().set_network_peer(host)
	
	_set_status("Connecting..",true)
	



### INITIALIZER ####
	
func _ready():
	# connect all the callbacks related to networking
	get_tree().connect("network_peer_connected",self,"_player_connected")
	get_tree().connect("network_peer_disconnected",self,"_player_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_ok")
	get_tree().connect("connection_failed",self,"_connected_fail")
	get_tree().connect("server_disconnected",self,"_server_disconnected")
	self.connect("player_list_change",self,"refresh_lobby")
	self.connect("connection_established",self,"on_connection_established")
	


