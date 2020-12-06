extends Spatial

var vanishTime = 1.0

func _process(delta):
	vanishTime -= delta
	if vanishTime <= 0.0:
		queue_free()
