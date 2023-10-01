extends Control


func _ready():
	if Global.playerData == null:
		visible = true
		$AnimationPlayer.play("FadeIn1")
		yield(get_tree().create_timer(2.5), "timeout")
		$AnimationPlayer.play("FadeIn2")
		yield(get_tree().create_timer(2.5), "timeout")
		$AnimationPlayer.play("FadeOut")
		yield(get_tree().create_timer(2), "timeout")
		visible = false
		
