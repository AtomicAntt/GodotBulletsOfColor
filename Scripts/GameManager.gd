extends Node2D

onready var enemyOne = preload("res://GameObjects/Enemy1.tscn")
onready var enemyTwo = preload("res://GameObjects/Enemy2.tscn")
onready var enemyThree = preload("res://GameObjects/Enemy3.tscn")

onready var weakEnemyOne = preload("res://GameObjects/WeakEnemy1.tscn")
onready var weakEnemyTwo = preload("res://GameObjects/WeakEnemy2.tscn")
onready var weakEnemyThree = preload("res://GameObjects/WeakEnemy3.tscn")

onready var topPositions = $TopPositions
onready var lowerPositions = $LowerPositions
onready var outerPositions = $OuterPositions

onready var weakEnemyTimer = $SpawnWeakEnemyTimer
onready var enemyTimer = $SpawnEnemyTimer

var score = 1000000
onready var scoreTween = get_node("In-Game UI/GameStatus/Tween")
onready var scoreLabel = get_node("In-Game UI/GameStatus/ScoreLabel")


var takenPositions = []
var availableLowerPos = []
var availableHigherPos = []

func _ready():
	Global.playerDead = false
	get_tree().paused = false
	weakEnemyTimer.start()
	enemyTimer.start()
	if Global.playerData != null:
		findLowerPositionsAndTweenEnemy()
		findLowerPositionsAndTweenEnemy()
	

func _on_RestartButton_pressed():
	Global.get_node("ConfirmSound").play()	
	get_tree().reload_current_scene()

func _on_QuitToMenuButton_pressed():
	Global.get_node("ConfirmSound").play()	
	get_tree().change_scene("res://Levels/MainMenu.tscn")

func _on_SpawnWeakEnemyTimer_timeout():
	weakEnemyTimer.start()
	findLowerPositionsAndTweenEnemy()

func _on_SpawnEnemyTimer_timeout():
	enemyTimer.start()
	findTopPositionsAndTweenEnemy()

func findTopPositionsAndTweenEnemy():
	availableHigherPos = []
	for _position in topPositions.get_children():
		if not _position in takenPositions:
			availableHigherPos.append(_position)
	
	var availablePos = len(availableHigherPos)
	
	if availablePos >= 1:
		var positionToTake = availableHigherPos[randi()%availablePos]
		takenPositions.append(positionToTake)
		var enemyInstance = returnRandomEnemy().instance()
		enemyInstance.position = returnClosestOuterPosition(positionToTake.position)
		add_child(enemyInstance)
		enemyInstance.positionTaken = positionToTake
		var tween = enemyInstance.get_node("Tween")
		tween.interpolate_property(enemyInstance, "position", enemyInstance.position, positionToTake.position, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()

func findLowerPositionsAndTweenEnemy():
	availableLowerPos = []
	for _position in lowerPositions.get_children():
		if not _position in takenPositions:
			availableLowerPos.append(_position)
	
	var availablePos = len(availableLowerPos)
	
	if availablePos >= 1:
		var positionToTake = availableLowerPos[randi()%availablePos]
		takenPositions.append(positionToTake)
		var enemyInstance = returnRandomWeakEnemy().instance()
		enemyInstance.position = returnClosestOuterPosition(positionToTake.position)
		add_child(enemyInstance)
		enemyInstance.positionTaken = positionToTake
		var tween = enemyInstance.get_node("Tween")
		tween.interpolate_property(enemyInstance, "position", enemyInstance.position, positionToTake.position, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
	
	
#	var found = false # debounce
#	for _position in lowerPositions.get_children():
#		if not _position in takenPositions and not found:
#			found = true
#			takenPositions.append(_position)
#			var enemyInstance = returnRandomWeakEnemy().instance()
#			enemyInstance.position = returnClosestOuterPosition(_position.position)
#			add_child(enemyInstance)
#			enemyInstance.positionTaken = _position			
#			var tween = enemyInstance.get_node("Tween")
#			tween.interpolate_property(enemyInstance, "position", enemyInstance.position, _position.position, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
#			tween.start()
			
			
func returnClosestOuterPosition(_position): # to the position given in parameter
	var dist = 9999
	var mostValidPosition = null
	for node in outerPositions.get_children():
		var nodeDistance = node.position.distance_to(_position)
		if nodeDistance < dist:
			dist = nodeDistance
			mostValidPosition = node.position
	return mostValidPosition
			
func returnRandomEnemy():
	var randomNum = randi()%3+1
	match randomNum:
		1:
			return enemyOne
		2:
			return enemyTwo
		3: 
			return enemyThree

func returnRandomWeakEnemy():
	var randomNum = randi()%3+1
	match randomNum:
		1:
			return weakEnemyOne
		2:
			return weakEnemyTwo
		3:
			return weakEnemyThree

func summonWeakIfNoEnemies(): # always give players something to do..
	if len(takenPositions) <= 0:
		findLowerPositionsAndTweenEnemy()

func increaseScore(increment):
	scoreTween.interpolate_method(self, "setText", score, score + increment, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	scoreTween.start()
	score += increment

func setText(num):
	scoreLabel.text = str(floor(num)).substr(1)
	
func _on_button_mouse_entered():
	Global.get_node("CursorEnteredSound").play()
