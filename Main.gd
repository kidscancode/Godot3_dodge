extends Node

export (PackedScene) var Mob
var score
var screensize

func _ready():
	randomize()
	screensize = get_viewport().get_size()
	
func new_game():
	score = 0
	$HUD.update_score(score)
	$Player.start($StartPos.position)
	$StartTimer.start()
	$HUD.show_message("Get Ready")
	$Music.play()
	
func game_over():
	$DeathSound.play()
	$Music.stop()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func _on_MobTimer_timeout():
	# choose a random location on the Path2D
	$"MobPath/MobSpawnLocation".set_offset(randi())
	var mob = Mob.instance()
	add_child(mob)
	var direction = $"MobPath/MobSpawnLocation".rotation
	mob.position = $"MobPath/MobSpawnLocation".position
	# add some randomness to the direction
	direction += rand_range(-PI/4, PI/4)
	# textures are oriented pointing up, so add 90deg
	mob.rotation = direction + PI/2
	mob.set_linear_velocity(Vector2(rand_range(mob.MIN_SPEED, mob.MAX_SPEED), 0).rotated(direction))
	
func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)
	