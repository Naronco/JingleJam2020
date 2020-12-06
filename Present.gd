extends Area

func _ready():
	connect("body_entered", self, "_on_body_enter")

func _on_body_enter(body):
	if body.get_name() == "Player":
		body.collect_present(self)
		queue_free()
