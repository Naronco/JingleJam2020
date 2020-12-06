extends Area

func _ready():
	connect("body_entered", self, "_on_body_enter")

func _on_body_enter(body):
	print("Entered")
	if body.get_name() == "Player":
		if body.health < body.MAX_HEALTH:
			body.do_damage(self, -1)
			queue_free()
