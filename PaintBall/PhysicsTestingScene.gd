extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var timer
var paintball

func _shoot():
	var ball = paintball.instance()
	add_child(ball)

func _ready():
	paintball = load("res://PaintBall/PaintBall.tscn")
	
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 2
	timer.one_shot = false
	timer.connect("timeout", self, "_shoot")
	add_child(timer)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
