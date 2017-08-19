extends Area2D

signal hit

var speed = 400
var vel = Vector2()
var screensize
var extents

func _ready():
	hide()
	screensize = get_viewport_rect().size
	
func start(pos):
	position = pos
	show()
	monitoring = true
			
func _process(delta):
	vel.x = Input.is_action_pressed("ui_right") - Input.is_action_pressed("ui_left")
	vel.y = Input.is_action_pressed("ui_down") - Input.is_action_pressed("ui_up")
	if vel.length() > 0:
		vel = vel.normalized() * speed
		$Sprite.play()
		#$Trail.emitting = true
	else:
		$Sprite.stop()
		#$Trail.emitting = false
		
	position += vel * delta
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)

	if vel.x != 0:
		$Sprite.animation = "right"
		$Sprite.flip_v = false
		$Sprite.flip_h = vel.x < 0
	elif vel.y != 0:
		$Sprite.animation = "up"
		$Sprite.flip_v = vel.y > 0
#	if vel.x > 0:
#		$Sprite.animation = "right"
#		$Sprite.flip_h = false
#		$Sprite.flip_v = false
#	elif vel.x < 0:
#		$Sprite.animation = "right"
#		$Sprite.flip_h = true
#		$Sprite.flip_v = false
#	elif vel.y > 0:
#		$Sprite.animation = "up"
#		$Sprite.flip_v = true
#	elif vel.y < 0:
#		$Sprite.animation = "up"
#		$Sprite.flip_v = false

func _on_Player_area_entered( area ):
	call_deferred("set_monitoring", false)
	hide()
	emit_signal("hit")
