extends KinematicBody2D

enum Colors {RED, BLUE, GREEN, YELLOW}

var speed = 300
var color # will be set by the enemy

func setProperties(setColor):
	color = setColor
	Global.setColor(setColor, self)

func _physics_process(delta):
	if not Global.playerDead:
		position += transform.x * speed * delta

func _on_KillTimer_timeout():
	queue_free()
