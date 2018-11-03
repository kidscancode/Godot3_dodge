extends CanvasLayer

signal start_game
			
func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	#yield($MessageTimer, "timeout")
	
func show_all():
	rpc("show_high_score")
	
sync func show_high_score():
	show_message("High Score\n"+str(rpc("get_high_score")))
	yield($MessageTimer, "timeout")
	$StartButton.show()
	$MessageLabel.text = "Dodge the\nCreeps!"
	$MessageLabel.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_StartButton_pressed():
	emit_signal("start_game")

func hide_hud():
	$StartButton.hide()
	$MessageLabel.hide()
	

func _on_MessageTimer_timeout():
	$MessageLabel.hide()