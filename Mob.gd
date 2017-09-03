extends Area2D

var MIN_SPEED = 200
var MAX_SPEED = 250
var mob_types = ["walk", "swim", "fly"]
var velocity
var screensize
var direction

func _ready():
	screensize = get_viewport_rect().size
	randomize()
	choose_start_location()
	$Sprite.animation = mob_types[randi() % mob_types.size()]
	
func choose_start_location():
	var edge = randi() % 4
	match edge:
		0:  # top
			position = Vector2(rand_range(0, screensize.x), 0)
			direction = PI/2
		1:  # right
			position = Vector2(screensize.x, rand_range(0, screensize.y))
			direction = PI
		2:  # bottom
			position = Vector2(rand_range(0, screensize.x), screensize.y)
			direction = PI * 3/2
		3:  # left
			position = Vector2(0, rand_range(0, screensize.y))
			direction = 0
			
	direction += rand_range(-PI/4, PI/4)
	# textures are oriented pointing up, so add 90deg
	rotation = direction + PI/2
	velocity = Vector2(rand_range(MIN_SPEED, MAX_SPEED), 0).rotated(direction)
	
func _process(delta):
	position += velocity * delta
	
func _on_Visible_screen_exited():
	queue_free()
