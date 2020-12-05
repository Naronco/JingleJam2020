extends KinematicBody

export(float) var throwFrequency = 5.0

var lastThrowTime = 0.0
var throwCount = 0
var player

const Snowball = preload("res://Snowball.tscn")

func _ready():
	pass

func _process(delta):
	lastThrowTime += delta
	
	if lastThrowTime >= 1 / throwFrequency and player != null:
		# Get player
		var throwDir = player.transform.origin - transform.origin
		throwDir.y = 0
		throwDir = throwDir.normalized()
		
		var snowball = Snowball.instance()
		snowball.velocity = 8 * throwDir
		
		var sideOffs = Vector3(throwDir.z, 0, -throwDir.x) * .3
		if throwCount % 2 == 1:
			sideOffs = -sideOffs
		
		snowball.transform.origin = transform.origin + 0.9 * throwDir + sideOffs + Vector3(0, 0.2, 0)
		get_parent().add_child(snowball)
		
		throwCount += 1
		lastThrowTime = 0.0

func set_player(p):
	player = p
