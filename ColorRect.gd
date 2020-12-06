extends ColorRect

func _init():
	pass

var time = 200.0 / 360.0
func _process(delta):
	time += delta
	color = Color.from_hsv(time * 0.02, 0.91, 0.6, 1)
	

func _on_play():
	get_tree().change_scene("res://main.tscn")
