extends Control

onready var bgSoundSlider = get_node("SettingScreen/BgSoundSlider")
onready var effectSoundSlider = get_node("SettingScreen/EffectSoundSlider")

onready var kbModeCheckBox = get_node("SettingScreen/KbModeCheckBox")
onready var mouseModeCheckBox = get_node("SettingScreen/MouseModeCheckBox")

onready var highScoreLabel = get_node("MainScreen/HighScoreLabel")

func _ready():
	Global.playerDead = false
	bgSoundSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Background")))
	effectSoundSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects")))
	mouseModeCheckBox.pressed = Global.mouseMode
	kbModeCheckBox.pressed = not Global.mouseMode
	get_tree().paused = false
	
	Global.loadData()
	
	if Global.playerData != null:
		highScoreLabel.text = "High Score: " + str(Global.playerData["HighScore"])
	else:
		print("no")
		highScoreLabel = "High Score: N/A"
	
func _on_LevelSelect_pressed():
	Global.get_node("ConfirmSound").play()
	get_tree().change_scene("res://Levels/GameManager.tscn")

func _on_Quit_pressed():
	get_tree().quit()

func _on_Settings_pressed():
	Global.get_node("ConfirmSound").play()	
	$MainScreen.visible = false
	$SettingScreen.visible = true

func _on_BackButton_pressed():
	Global.get_node("ConfirmSound").play()	
	$SettingScreen.visible = false
	$MainScreen.visible = true

func _on_button_mouse_entered():
	Global.get_node("CursorEnteredSound").play()

func _on_BgSoundSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background"), linear2db(value))

func _on_EffectSoundSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear2db(value))
	
func _on_KbModeCheckBox_toggled(button_pressed):
	if button_pressed:
		Global.mouseMode = false
		mouseModeCheckBox.pressed = false
		kbModeCheckBox.disabled = true
		mouseModeCheckBox.disabled = false

func _on_MouseModeCheckBox_toggled(button_pressed):
	if button_pressed:
		Global.mouseMode = true
		kbModeCheckBox.pressed = false
		mouseModeCheckBox.disabled = true
		kbModeCheckBox.disabled = false
