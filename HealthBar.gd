extends TextureRect

const MAX_HEALTH = 10

export(int) var health = MAX_HEALTH

func _ready():
	pass

func set_health(h):
	if h <= 0:
		health = 0
		visible = false
		return
	elif h > MAX_HEALTH:
		health = MAX_HEALTH
	else:
		health = h
	visible = true
	texture.set_region(Rect2(h / (MAX_HEALTH / 2) * 64, (h % (MAX_HEALTH / 2)) * 24, 64, 24))
