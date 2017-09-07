extends RigidBody2D

var MIN_SPEED = 150
var MAX_SPEED = 250
var mob_types = ["walk", "swim", "fly"]

func _ready():
	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]
	
func _on_Visibility_screen_exited():
	queue_free()
