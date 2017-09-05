extends Area2D

var MIN_SPEED = 150
var MAX_SPEED = 250
var mob_types = ["walk", "swim", "fly"]
var velocity = Vector2()

func _ready():
	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]
	
func _process(delta):
	position += velocity * delta
	
func _on_Visibility_screen_exited():
	queue_free()
