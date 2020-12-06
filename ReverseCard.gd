extends Area

var elapsedTime = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_body_enter")

func _on_body_enter(body):
	print("Entered")
	if body.get_name() == "Player":
		body.flip_gravity()
		queue_free()

func _process(delta):
	elapsedTime += delta
	$Sprite3D.transform.origin.y = 0.1 + 0.1 * sin(4 * elapsedTime)
