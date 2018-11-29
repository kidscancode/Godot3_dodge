extends Node

#var alive = 1

export (PackedScene) var Mob
var score
var alive
var high_score = []
signal game_finished()
#signal updated_high_score()


func _ready():
	randomize()
	
func send_new_game():
	rpc("new_game")
	
#func send_game_over():
	#rpc("game_over")

sync func new_game():
	score = 0
	alive = 1
	$HUD.hide_hud()
	$HUD.update_score(score)
	$Player.start($StartPosition.position)
	
	for p in $players.get_children():
		p.start($StartPosition.position)
		p.connect("hit", self, "check_game_over")
		print("Adding player" + str(p))
		alive += 1
	$StartTimer.start()
	$HUD.show_message("Get Ready")
	$Music.play()

func check_game_over():
	alive -= 1
	print("Alive: "+str(alive))
	if (alive <= 0):
		rpc("game_over")
	
sync func game_over():
	$DeathSound.play()
	$Music.stop()
	$ScoreTimer.stop()
	$MobTimer.stop()
	#rpc("update_high_score")
	#$HighScoreTimer.start()
	#yield($HighScoreTimer,"timeout")
	$HUD.show_game_over()

#sync func update_high_score():
	#high_score.push_front(score)
	
#remote func get_high_score():
	#return high_score[0]
	
master func _on_MobTimer_timeout():
	# choose a random location on the Path2D
	if (get_tree().is_network_server()):
		var offset = randi()
		$MobPath/MobSpawnLocation.set_offset(offset)
		var mob = Mob.instance()
		add_child(mob)
		var direction = $MobPath/MobSpawnLocation.rotation + PI/2
		mob.position = $MobPath/MobSpawnLocation.position
		# add some randomness to the direction
		#direction += rand_range(-PI/4, PI/4)
		mob.rotation = direction
		var speed = rand_range(mob.MIN_SPEED, mob.MAX_SPEED)
		rpc("mobTimer_sync", speed, offset, direction, mob.position)
		mob.set_linear_velocity(Vector2(speed, 0).rotated(direction))
	
	
remote func mobTimer_sync(speed, off, dir, mobPos):
	$MobPath/MobSpawnLocation.set_offset(off)
	var mob = Mob.instance()
	add_child(mob)
	mob.position = mobPos
	mob.rotation = dir
	mob.set_linear_velocity(Vector2(speed, 0).rotated(dir))
	
func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)
	
#remote func _on_death():
	#rpc("decrement_alive")
	
#sync func decrement_alive():
	#alive = alive - 1
	#print(alive)
	#if (alive < 1):
		#$HUD.show_all()
