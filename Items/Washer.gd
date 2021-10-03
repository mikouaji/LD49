extends MeshInstance

const plateScene = preload("res://Items/Plate.tscn")

signal plate_delivery

func _onEnter(body):
	if body.get_filename() == plateScene.get_path():
		emit_signal("plate_delivery")
		$AudioStreamPlayer.play()
		$Timer.start()
		$Particles.emitting = true
		body.bork(true)



func _on_Timer_timeout():
	$AudioStreamPlayer.stop()
	$Particles.emitting = false
