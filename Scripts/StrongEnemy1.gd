extends "res://Scripts/Enemy.gd"

func _ready():
	rotationSpeed = 0 # 100
	shootingTime = 0.7 # 0.2
	spawnPointCount = 1
	radius = 90 # 90
	health = 100 # 100
	pelletNum = 8 # 4
	degreeShot = 90 # 90
	enemyType = 2
	difficulty = 1
