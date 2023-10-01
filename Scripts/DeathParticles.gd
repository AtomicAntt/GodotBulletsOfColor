extends Particles2D

func _on_DeathSound_finished():
	queue_free()
