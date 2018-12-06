extends CanvasLayer

signal start_game
var best_score = 0
			
func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()

func show_game_over(score):
	show_message("Game Over")
	yield($MessageTimer, "timeout")
	if (score > best_score):
		best_score = score
		show_message("New High Score!\n"+str(score))
		update_high_score(score)
		yield($MessageTimer, "timeout")
	$StartButton.show()
	$MessageLabel.text = "Dodge the\nCreeps!"
	$MessageLabel.show()
	$HighScoreLabel.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func update_high_score(score):
	$HighScoreLabel.text = "High Score: "+str(score)

func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")

func _on_MessageTimer_timeout():
	$MessageLabel.hide()
	
func hide_hud():
	$StartButton.hide()
	$MessageLabel.hide()
	$HighScoreLabel.hide()