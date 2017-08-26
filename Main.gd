extends Node

var Mob = preload("res://Mob.tscn")
var score

func _ready():
	$Player.connect("hit", self, "game_over")
	$HUD.connect("start_game", self, "new_game")
	
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
	$HUD.game_over()

func _on_MobTimer_timeout():
	add_child(Mob.instance())

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)
