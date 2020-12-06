extends KinematicBody

export(float) var throwFrequency = 5.0

var lastThrowTime = 0.0
var throwCount = 0
var player

var rng = RandomNumberGenerator.new()

var randomWalkDir = Vector3()
var lastWalkDirChangeTime = 0.0
var newDirTime = rng.randf_range(0.5, 2.0)

var velocity = Vector3()

func _ready():
	rng.randomize()
	lastThrowTime = rng.randf_range(-1, 0)

func _physics_process(delta):
	lastThrowTime += delta
	lastWalkDirChangeTime += delta
	
	if lastWalkDirChangeTime >= newDirTime:
		var angle = rng.randf_range(0, 2 * PI)
		randomWalkDir = Vector3(cos(angle), 0, sin(angle)) * 10.0
		lastWalkDirChangeTime = 0.0
		newDirTime = rng.randf_range(0.5, 2.0)
	
	velocity = randomWalkDir * delta
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
	if lastThrowTime >= 1 / throwFrequency and player != null:
		# Get player
		# Jump to the player
		pass

func set_player(p):
	player = p
