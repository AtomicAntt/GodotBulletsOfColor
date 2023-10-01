extends Node

enum Colors {RED, BLUE, GREEN, YELLOW}

var crosshair = preload("res://GameAssets/crosshair.png")
var playerDead = false

var mouseMode = true
onready var confirmSound = $ConfirmSound

# to be saved content:

var playerData = null

var savePath = "user://save.dat"

func saveData(highScore):
	var data = {
		"HighScore" : highScore,
		"FirstTime" : true
	}
	var file = File.new()
	var error = file.open(savePath, File.WRITE)
	if error == OK:
		file.store_var(data)
		file.close()

func loadData():
	var file = File.new()
	if file.file_exists(savePath):
		var error = file.open(savePath, File.READ)
		if error == OK:
			playerData = file.get_var()
			file.close()
			print(playerData)

func _ready():
	Input.set_custom_mouse_cursor(crosshair, Input.CURSOR_ARROW, Vector2(36,36))

func setColor(color, node):
	match color:
		Colors.RED:
			node.modulate = Color("f92c2c")
		Colors.BLUE:
			node.modulate = Color("2777f4")
		Colors.GREEN:
			node.modulate = Color("156518")
		Colors.YELLOW:
			node.modulate = Color("e2e812")
