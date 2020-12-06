extends Area

var elapsedTime = 0.0
var respawnTime = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_body_enter")

func _on_body_enter(body):
	if !visible:
		return

	print("Entered")
	if body.get_name() == "Player":
		body.flip_gravity()
		visible = false
		respawnTime = 10

func _process(delta):
	if !visible:
		respawnTime -= delta
		if respawnTime < 0:
			visible = true
	else:
		elapsedTime += delta
		$Sprite3D.transform.origin.y = 0.1 + 0.1 * sin(4 * elapsedTime)
