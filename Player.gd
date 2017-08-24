extends Area2D

signal hit

var speed = 400
var velocity = Vector2()
var screensize

func _ready():
	hide()
	screensize = get_viewport_rect().size
	
func start(pos):
	position = pos
	show()
	monitoring = true
			
func _process(delta):
	velocity.x = Input.is_action_pressed("ui_right") - Input.is_action_pressed("ui_left")
	velocity.y = Input.is_action_pressed("ui_down") - Input.is_action_pressed("ui_up")
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$Sprite.play()
	else:
		$Sprite.stop()
		
	position += velocity * delta
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)

	if velocity.x != 0:
		$Sprite.animation = "right"
		$Sprite.flip_v = false
		$Sprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$Sprite.animation = "up"
		$Sprite.flip_v = velocity.y > 0

func _on_Player_area_entered( area ):
	call_deferred("set_monitoring", false)
	hide()
	emit_signal("hit")
