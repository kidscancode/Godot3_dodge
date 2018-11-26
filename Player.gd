extends Area2D

signal hit

export (int) var SPEED
var velocity = Vector2()
var screensize
slave var slave_pos = Vector2()
slave var slave_velocity = Vector2()
#var main = load("res://Main.gd").new()


func _ready():
	hide()
	slave_pos = position
	screensize = get_viewport_rect().size

func start(pos):
	position = pos
	show()
	$Collision.disabled = false

func _process(delta):
	velocity = Vector2()
	if (is_network_master()):
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
		if velocity.length() > 0:
			velocity = velocity.normalized() * SPEED
			$AnimatedSprite.play()
			$Trail.emitting = true
		else:
			$AnimatedSprite.stop()
			$Trail.emitting = false
		
		#slave_pos += velocity * delta
		#slave_pos.x = clamp(position.x, 0, screensize.x)
		#slave_pos.y = clamp(position.y, 0, screensize.y)
		rset("slave_velocity", velocity)
		rset("slave_pos", position)
		position += velocity * delta
		position.x = clamp(position.x, 0, screensize.x)
		position.y = clamp(position.y, 0, screensize.y)
	else:
		position += slave_velocity * delta
		position.x = clamp(position.x, 0, screensize.x)
		position.y = clamp(position.y, 0, screensize.y)
		position = slave_pos
		#velocity = slave_velocity

	if velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0
	if (not is_network_master()):
		slave_pos = position	
		


func _on_Player_body_entered( body ):
	$Collision.disabled = true
	hide()
	#main._on_death()
	emit_signal("hit")


