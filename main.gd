extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var time = 0
var audio_file_path = "res://TitleAudio/title"
var a = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	a.randomize()
	var val = a.randi_range(1, 9)       # pick a valid random number
	var path = audio_file_path+str(val)+".wav"
	if File.new().file_exists(path):
		var sfx = load(path)
		$Intro.stream = sfx
		$Intro.volume_db = -6
		$Intro.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#time += delta
	#$ColorGradingFilter.temperature = sin(time)
	#$ColorGradingFilter.update()


func _on_rubberduck_arrived_at_port():
	$test1/Crane.pickupField = $test1/Crane.get_path_to($rubberduck/ContainerField)


func _on_rubberduck_leaving_port():
	$test1/Crane.pickupField = null
