extends KinematicBody2D

# https://www.youtube.com/watch?v=Z2TaFnN7cdU&

var bullet = preload("res://GameObjects/Bullet.tscn")
var deathParticles = preload("res://GameObjects/DeathParticles.tscn")

onready var shootTimer = $ShootTimer
onready var rotater = $Rotater

var rotationSpeed = 100 # 100
var shootingTime = 0.2 # 0.2
var spawnPointCount = 8 # 4
var radius = 90 # 90

var positionTaken = null # for GameManager to decide which position they are located in

var enemyType = 1 # 1 is spiral, 2 is shotgun, 3 is static shape shooting
var difficulty = 1 # 1 is hard, 2 is weak

# if shotgun, use these properties

var pelletNum = 7
var degreeShot = 90.0

var arrayOfAngles = [] #setup on ready

var player = null

onready var tween = $Tween
onready var healthOver = $HealthOver
onready var healthUnder = $HealthUnder

var maxHealth = 100.0
var health # on ready, it gets set to max health

var velocity = Vector2(100, 100)

enum Colors {RED, BLUE, GREEN, YELLOW}

func _ready():
	health = maxHealth
	player = get_tree().get_nodes_in_group("player")[0]
	
	yield(get_tree().create_timer(0.001), "timeout")
	
	var step = 2 * PI / spawnPointCount
	
	
	for i in range(spawnPointCount):
		var spawnPoint = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawnPoint.position = pos
		spawnPoint.rotation = pos.angle()
		rotater.add_child(spawnPoint)
	
	# BOOTLEG SHOTGUN ANGLES GENERATOR
	
	if pelletNum % 2 != 0: # if the amount of pellets is odd, one angle will be 0 (3 will be som like -45, 0, 45 at 90 deg)
		pelletNum -= 1
		arrayOfAngles.append(0)
	
	var startDeg = -(degreeShot / 2) # -45
	for i in range(pelletNum):
		arrayOfAngles.append(startDeg)
		startDeg += (degreeShot / pelletNum)
		if startDeg == 0:
			startDeg += (degreeShot/pelletNum)
		
	shootTimer.wait_time = shootingTime
	shootTimer.start()

func _process(delta):
	var newRotation = rotater.rotation_degrees + rotationSpeed * delta
	rotater.rotation_degrees = fmod(newRotation, 360)

#func _physics_process(delta):
#	var collisionInfo = move_and_collide(velocity * delta)
#	if collisionInfo and  not collisionInfo.collider.is_in_group("rocket"):
#		velocity = velocity.bounce(collisionInfo.normal)
	

func _on_ShootTimer_timeout():
	if Global.playerDead:
		return
	var playerLocation = get_tree().get_nodes_in_group("player")[0].position
	var dir = position.direction_to(playerLocation)
	match enemyType:
		1: # spiral
			for s in rotater.get_children(): 
				var bulletInstance = bullet.instance()
				chooseColor(bulletInstance)
				bulletInstance.position = s.global_position
				bulletInstance.rotation = s.global_rotation
				get_parent().add_child(bulletInstance)		
		2: # shotgun
			for angle in arrayOfAngles:
				var radians = deg2rad(angle)
				var bulletInstance = bullet.instance()
				chooseColor(bulletInstance)
				bulletInstance.rotation = dir.rotated(radians).angle()
				bulletInstance.position = position
				get_parent().add_child(bulletInstance)
		3: # circle
			for s in rotater.get_children():
				var bulletInstance = bullet.instance()
				chooseColor(bulletInstance)
				bulletInstance.rotation = dir.angle()
				bulletInstance.position = s.global_position
				get_parent().add_child(bulletInstance)
			

func chooseColor(bulletInstance):
	var randomNum = randi()%2+1
	match randomNum:
		1: 
			bulletInstance.setProperties(player.playerColor)
		2:
			var randomNum2 = randi()%4+1
			match randomNum2:
				1: 
					bulletInstance.setProperties(Colors.RED)
				2:
					bulletInstance.setProperties(Colors.BLUE)
				3:
					bulletInstance.setProperties(Colors.GREEN)
				4:
					bulletInstance.setProperties(Colors.YELLOW)


func _on_Area2D_body_entered(body):
	if body.is_in_group("rocket"):
		body.queue_free()
		health -= 13
		updateHealthBar()
		if health <= 0: # death
			var deathParticlesInstance = deathParticles.instance()
			var gameManager = get_tree().get_nodes_in_group("gamemanager")[0]
			gameManager.takenPositions.erase(positionTaken)
			gameManager.summonWeakIfNoEnemies()
			if difficulty == 1:
				gameManager.increaseScore(300)
			elif difficulty == 2:
				gameManager.increaseScore(125)
			deathParticlesInstance.position = position
			deathParticlesInstance.emitting = true
			deathParticlesInstance.get_node("DeathSound").play()
			get_parent().add_child(deathParticlesInstance)
			queue_free()
		else:
			$HurtSound.play()
		

func updateHealthBar():
	tween.interpolate_property(healthUnder, "value", healthUnder.value, (health / maxHealth) * 100, 0.4, tween.TRANS_SINE, tween.EASE_IN_OUT)
	tween.start()
	healthOver.value = (health / maxHealth) * 100
