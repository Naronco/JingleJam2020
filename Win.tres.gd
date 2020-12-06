extends Control

onready var GlobalState = get_node("/root/GlobalState")

func _ready():
	$Label/Control.visible = GlobalState.wonWithCats
	$Label/Control3.visible = GlobalState.wonWithCats
	$Label/Control4.visible = GlobalState.wonWithCats
	$Label/Control5.visible = GlobalState.wonWithCats
	$Label/Control6.visible = GlobalState.wonWithCats

var time = 200.0 / 360.0
func _process(delta):
	time += delta
	$ColorRect.color = Color.from_hsv(time * 0.02, 0.91, 0.6, 1)
