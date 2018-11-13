extends Control

const DEFAULT_PORT = 8910 
const MAX_PEERS = 4

#vars
var players = {}
var spawns = {}
var player_name

#signals
signal player_list_change()
signal connection_established()


#gamestate functions

remote func pre_start_game(spawns):
	# Change scene
	var game = load("res://Main.tscn").instance()
	game.connect("game_finished",self,"_end_game",[],CONNECT_DEFERRED) 
	get_tree().get_root().add_child(game)

	#get_tree().get_root().get_node("lobby").hide()
	
	var player_scene = load("res://Player.tscn")
	
	for p_id in spawns: #players
		#var spawn_pos = world.get_node("spawn_points/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()
		print("Added player instance: " + str(p_id))
		
		player.set_name(str(p_id)) # Use unique ID as node name
		#player.position=spawn_pos
		player.set_network_master(p_id) #set unique id as master

		game.get_node("players").add_child(player)
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false)

	# Set up score
	#game.get_node("score").add_player(get_tree().get_network_unique_id(), player_name)
	#for pn in players:
		#game.get_node("score").add_player(pn, players[pn])

	#if (not get_tree().is_network_server()):
		# Tell server we are ready to start
		#rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	#elif players.size() == 0:
		#post_start_game()

#when server sees client connect, load waiting area (server only)
func _player_connected(id):
	#_load_game()
	#emit_signal("player_list_change")
	pass

func _player_disconnected(id):
	if (get_tree().is_network_server()):
		if (has_node("/root/Main")): # Game is in progress
			if(has_node("/root/Main/players/" + str(id))):
				get_node("/root/Main/players/" + str(id)).queue_free() #remove player scene who disconnected mid-game
			#emit_signal("game_error", "Player " + players[id] + " disconnected")
			unregister_player(id)
			
			#end_game()
		else: # Game is not in progress
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)

#when client connects, load waiting area (client only)
func on_connection_established(): 
	get_node("Connect").hide()
	get_node("Players").show()
	
#func send_load_game():
#	rpc("_load_game")
	
#sync func _load_game():
#	print("LOADING")
#	var game = load("res://Main.tscn").instance()
#	game.connect("game_finished",self,"_end_game",[],CONNECT_DEFERRED) 
#	get_tree().get_root().add_child(game)

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
	
remote func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_change")
	

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
	players.clear()
	emit_signal("player_list_change")
	get_node("Players").hide()
	get_node("Connect").show()
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
	refresh_lobby()
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
	
	
func get_player_list():
	return players.values()
	
func _on_start_pressed():
	assert(get_tree().is_network_server())
	spawns[1] = 1
	print("Added spawn for: " + str(spawns[1]))
	for p_id in players:
		spawns[p_id] = p_id
		print("Added spawn for: " + str(spawns[p_id]))
	for p in players:
		rpc_id(p, "pre_start_game", spawns)
	pre_start_game(spawns)
	#print(get_player_list())
	

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
	






