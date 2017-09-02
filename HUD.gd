extends CanvasLayer

signal start_game
	
func _input(event):
	if event.is_action_pressed("ui_select"):
		if $StartButton.is_visible():
			$StartButton.emit_signal("pressed")
			
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	yield($MessageTimer, "timeout")
	$StartButton.show()
	$Message.text = "Dodge the\nCreeps!"
	$Message.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")

func _on_MessageTimer_timeout():
	$Message.hide()