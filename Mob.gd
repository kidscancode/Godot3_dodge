extends Area2D

var MIN_SPEED = 200
var MAX_SPEED = 250
var mob_types = ["walk", "swim", "fly"]
var vel = Vector2()
var screensize
var dir

func _ready():
	screensize = get_viewport_rect().size
	randomize()
	choose_start_location()
	$Sprite.animation = mob_types[randi() % mob_types.size()]
	
func choose_start_location():
	var edge = randi() % 4
	if edge == 0:  # top
		position = Vector2(rand_range(0, screensize.x), 0)
		dir = PI/2
	elif edge == 1:  # right
		position = Vector2(screensize.x, rand_range(0, screensize.y))
		dir = PI
	elif edge == 2:  # bottom
		position = Vector2(rand_range(0, screensize.x), screensize.y)
		dir = PI * 3/2
	elif edge == 3:  # left
		position = Vector2(0, rand_range(0, screensize.y))
		dir = 0
	dir += rand_range(-PI/4, PI/4)
	# textures are oriented pointing up, so add 90deg
	rotation = dir + PI/2
	vel = Vector2(rand_range(MIN_SPEED, MAX_SPEED), 0).rotated(dir)
	
func _process(delta):
	position += vel * delta
	
func _on_Visible_screen_exited():
	queue_free()
