extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	#$ColorGradingFilter.temperature = sin(time)
	#$ColorGradingFilter.update()


func _on_rubberduck_arrived_at_port():
	$test1/Crane.pickupField = $test1/Crane.get_path_to($rubberduck/ContainerField)


func _on_rubberduck_leaving_port():
	$test1/Crane.pickupField = null
