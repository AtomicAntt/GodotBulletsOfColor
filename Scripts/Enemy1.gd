extends "res://Scripts/Enemy.gd"

func _ready():
	rotationSpeed = 0 # 100
	shootingTime = 1.2 # 0.2
	spawnPointCount = 4 # 4
	radius = 90 # 90
	health = 36 # 100
	pelletNum = 8 # 4
	degreeShot = 90 # 90
	enemyType = 3
	difficulty = 2
