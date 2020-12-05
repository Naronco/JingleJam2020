extends KinematicBody

export(float) var throwFrequency = 5.0

var lastThrowTime = 0.0
var player

const Snowball = preload("res://Snowball.tscn")

func _ready():
	pass

func _process(delta):
	lastThrowTime += delta
	
	if lastThrowTime >= 1 / throwFrequency:
		# Get player
		var throwDir = player.transform.origin - transform.origin
		throwDir.y = 0
		throwDir = throwDir.normalized()
		
		var snowball = Snowball.instance()
		snowball.velocity = 8 * throwDir
		snowball.transform.origin = transform.origin + throwDir
		get_parent().add_child(snowball)
		
		lastThrowTime = 0.0

func set_player(p):
	player = p
