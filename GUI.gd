extends Control

onready var GlobalState = get_node("/root/GlobalState")

var lastPresents = 0
var numPresents = 0
var lastCats = 0
var numCats = 0

func _ready():
	numPresents = get_tree().get_nodes_in_group("Presents").size()
	numCats = get_tree().get_nodes_in_group("Cats").size()
	$PresentsIcon/PresentsCounter.text = str(lastPresents) + " / " + str(numPresents)
	$CatIcon/CatsCounter.text = str(lastCats) + " / " + str(numCats)

func _process(delta):
	if lastPresents != GlobalState.presents:
		lastPresents = GlobalState.presents
		$PresentsIcon/PresentsCounter.text = str(lastPresents) + " / " + str(numPresents)

	if lastCats != GlobalState.cats:
		lastCats = GlobalState.cats
		$CatIcon/CatsCounter.text = str(lastCats) + " / " + str(numCats)
