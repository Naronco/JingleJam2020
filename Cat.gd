extends Area

func _ready():
	connect("body_entered", self, "_on_body_enter")

func _on_body_enter(body):
	print("Entered")
	if body.get_name() == "Player":
		queue_free()
