extends KinematicBody2D

var speed = 450
var steerForce = 80

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

func start(startingTransform, setTarget): # method called by the player
	global_transform = startingTransform
	rotation += rand_range(-0.09, 0.09)
	target = setTarget
	velocity = transform.x * speed

func seek():
	var steer = Vector2.ZERO
	if target and is_instance_valid(target):
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steerForce
	elif len(get_tree().get_nodes_in_group("enemy")) > 0:
		target = returnClosestEnemy()
	return steer

func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	rotation = velocity.angle()
	position += velocity * delta
	
func _on_KillTimer_timeout():
	queue_free()

func returnClosestEnemy():
	var dist = 9999999 #this is the base
	var mostValidEnemy = null
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var enemyDistance = enemy.position.distance_to(self.position)
		if enemyDistance < dist:
			mostValidEnemy = enemy
			dist = enemyDistance
	return mostValidEnemy
