extends TextureRect

const MAX_HEALTH = 10

export(int) var health = MAX_HEALTH

func _ready():
	pass

func set_health(h):
	if h <= 0:
		health = 0
		visible = false
		get_parent().get_node("DeathScreen").visible = true
		return
	elif h > MAX_HEALTH:
		health = MAX_HEALTH
	else:
		health = h
	visible = true
	var hh : int = MAX_HEALTH - h
	texture.set_region(Rect2(((hh / (MAX_HEALTH / 2)) as int) * 64, ((hh as int) % ((MAX_HEALTH / 2) as int)) * 24, 64, 24))
