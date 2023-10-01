extends KinematicBody2D

var movementSpeed = 800
var rocket = preload("res://GameObjects/Rocket.tscn")
var emptyHeart = preload("res://GameAssets/EmptyHeart.png")
var heart = preload("res://GameAssets/Heart.png")
var deathParticles = preload("res://GameObjects/DeathParticles.tscn")

var immune = false
var maxLives = 5
var livesLeft

enum Colors {RED, BLUE, GREEN, YELLOW}
onready var gameUI = get_tree().get_nodes_in_group("ui")[0]
var playerColor

func _ready():
	livesLeft = maxLives
	playerColor = Colors.BLUE
	Global.setColor(playerColor, self) # visually

func _physics_process(delta):
	if not Global.mouseMode and not Global.playerDead:
		var motion = Vector2()
		
		if Input.is_action_pressed("up"):
			motion.y -= 1
		if Input.is_action_pressed("down"):
			motion.y += 1
		if Input.is_action_pressed("right"):
			motion.x += 1
		if Input.is_action_pressed("left"):
			motion.x -= 1
			
		motion = motion.normalized()
		motion = move_and_slide(motion * movementSpeed)
	elif not Global.playerDead:
#		var motion = Vector2()
#		var dir = get_global_mouse_position() - position
#		if dir.length_squared() >= 100:
#			move_and_slide(dir.normalized() * movementSpeed)
		
		position = get_global_mouse_position()


func _on_Area2D_body_entered(body):
	if body.is_in_group("bullet") and not Global.playerDead:
		if body.color == playerColor and not immune:
			hurt()
			body.queue_free()
		elif body.color != playerColor:
			$TransformSound.play()
			body.queue_free()
			var rocketInstance = rocket.instance()
			rocketInstance.start(self.transform, returnClosestEnemy())
			get_parent().add_child(rocketInstance)

func gameOver():
	Global.playerDead = true
	visible = false
	
	var scoreLabel = gameUI.get_node("GameOver/VBoxContainer2/ScoreLabel")
	var highScoreLabel = gameUI.get_node("GameOver/VBoxContainer2/HighScoreLabel")
	var prevHighScoreControl = gameUI.get_node("GameOver/PrevHighScoreControl")
	var prevHighScoreLabel = gameUI.get_node("GameOver/PrevHighScoreControl/PreviousHighScoreLabel")
	var gameMusic = get_tree().get_nodes_in_group("gamemanager")[0].get_node("GameMusic")
	var deathParticlesInstance = deathParticles.instance()
	gameMusic.stop()
	
	
	deathParticlesInstance.position = position
	deathParticlesInstance.emitting = true
	deathParticlesInstance.get_node("DeathSound").play()
	deathParticlesInstance.modulate = self.modulate
	get_parent().add_child(deathParticlesInstance)
	
	yield(get_tree().create_timer(0.8), "timeout")
	
	get_tree().paused = true
	updateHearts()
	gameUI.get_node("GameOver").visible = true
	var calculatedScore = get_tree().get_nodes_in_group("gamemanager")[0].score - 1000000
	scoreLabel.text = "Score: " + str(calculatedScore)
	if Global.playerData != null:
		if Global.playerData["HighScore"] < calculatedScore:
			prevHighScoreControl.visible = true
			prevHighScoreLabel.text = "Previous High Score: " + str(Global.playerData["HighScore"])
			Global.saveData(calculatedScore)			
	else: # if it is null.. this is a new game
		prevHighScoreControl.visible = true
		prevHighScoreLabel.text = "Previous High Score: 0" 
		Global.saveData(calculatedScore)
	
	Global.loadData()
	highScoreLabel.text = "Highscore: " + str(Global.playerData["HighScore"])
	

func returnClosestEnemy():
	var dist = 9999999 #this is the base
	var mostValidEnemy = null
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var enemyDistance = enemy.position.distance_to(self.position)
		if enemyDistance < dist:
			mostValidEnemy = enemy
			dist = enemyDistance
	return mostValidEnemy

func hurt():
	livesLeft -= 1
	if livesLeft <= 0:
		gameOver()
	elif not immune:
		immune = true
		updateHearts()
		$CollisionShape2D.set_deferred("Disabled", true)
		$HurtSound.play()
		$AnimationPlayer.play("flash")
		$ImmunityTimer.start()

func _on_ImmunityTimer_timeout():
	$CollisionShape2D.set_deferred("Disabled", false)
	$AnimationPlayer.stop()
	visible = true
	immune = false

func updateHearts():
	var heartContainer = get_parent().get_node("In-Game UI/GameStatus/HBoxContainer")
	var counter = 0
	for heart in heartContainer.get_children():
		counter += 1
		if livesLeft < counter:
			heart.texture = emptyHeart
		
