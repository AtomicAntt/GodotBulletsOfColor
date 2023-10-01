extends CanvasLayer

onready var pauseMenu = $PauseMenu
var prevMousePos = Vector2() # teleport mouse back to the player position lo
var totalScore

func _input(event):
	var playerLivesLeft = get_tree().get_nodes_in_group("player")[0].livesLeft
	
	if event.is_action_pressed("ui_cancel") and playerLivesLeft > 0:
		if not pauseMenu.visible:
			prevMousePos = get_viewport().get_mouse_position()
			get_tree().paused = true
			pauseMenu.visible = true
		else:
			if Global.mouseMode:
				get_viewport().warp_mouse(prevMousePos)
			yield(get_tree().create_timer(0.01), "timeout")
			get_tree().paused = false
			pauseMenu.visible = false


func _on_ResumeButton_pressed():
	Global.get_node("ConfirmSound").play()	
	if Global.mouseMode:
		get_viewport().warp_mouse(prevMousePos)
	yield(get_tree().create_timer(0.01), "timeout")
	get_tree().paused = false
	$PauseMenu.visible = false
