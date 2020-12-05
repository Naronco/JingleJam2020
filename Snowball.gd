extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var damage = 1.0
export(Vector3) var velocity = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Instantiated snowball")
	connect("body_entered", self, "_on_body_enter")

func _on_body_enter(body):
	print("Entered")
	if body.get_name() == "Player":
		body.do_damage(self, damage)
	
	# Play snowball destroy anim
	print("Deleting snowball")
	queue_free()

func _process(delta):
	transform.origin += delta * velocity
