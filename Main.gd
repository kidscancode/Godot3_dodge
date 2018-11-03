extends Node

var alive = 2

export (PackedScene) var Mob
var score
var high_score = []
signal game_finished()
signal updated_high_score()


func _ready():
	randomize()
	
func send_new_game():
	rpc("new_game")
	
#func send_game_over():
	#rpc("game_over")

sync func new_game():
	score = 0
	$HUD.hide_hud()
	$HUD.update_score(score)
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.show_message("Get Ready")
	$Music.play()
	
func game_over():
	$DeathSound.play()
	$Music.stop()
	$ScoreTimer.stop()
	$MobTimer.stop()
	rpc("update_high_score")
	$HighScoreTimer.start()
	yield($HighScoreTimer,"timeout")
	$HUD.show_game_over()

sync func update_high_score():
	high_score.push_front(score)
	
remote func get_high_score():
	return high_score[0]
	
func _on_MobTimer_timeout():
	# choose a random location on the Path2D
	$MobPath/MobSpawnLocation.set_offset(randi())
	var mob = Mob.instance()
	add_child(mob)
	var direction = $MobPath/MobSpawnLocation.rotation + PI/2
	mob.position = $MobPath/MobSpawnLocation.position
	# add some randomness to the direction
	#direction += rand_range(-PI/4, PI/4)
	mob.rotation = direction
	mob.set_linear_velocity(Vector2(rand_range(mob.MIN_SPEED, mob.MAX_SPEED), 0).rotated(direction))
	
func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	print("start timer")

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)
	
remote func _on_death():
	rpc("decrement_alive")
	
sync func decrement_alive():
	alive = alive - 1
	print(alive)
	if (alive < 1):
		$HUD.show_all()