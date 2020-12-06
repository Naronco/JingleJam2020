extends KinematicBody

export(float) var throwFrequency = 5.0
export(bool) var walkingEnabled = false
export(float) var walkingSpeedMin = 0.2
export(float) var walkingSpeedMax = 1.0

var lastThrowTime = 0.0
var throwCount = 0
var player

var rng = RandomNumberGenerator.new()

var randomWalkDir = Vector3()
var lastWalkDirChangeTime = 0.0
var newDirTime = rng.randf_range(0.5, 2.0)

var velocity = Vector3()

const Snowball = preload("res://Snowball.tscn")

func _ready():
	rng.randomize()
	lastThrowTime = rng.randf_range(-1, 0)

func _physics_process(delta):
	lastThrowTime += delta
	lastWalkDirChangeTime += delta
	
	if lastWalkDirChangeTime >= newDirTime:
		var angle = rng.randf_range(0, 2 * PI)
		randomWalkDir = Vector3(cos(angle), 0, sin(angle)) * rng.randf_range(walkingSpeedMin, walkingSpeedMax)
		lastWalkDirChangeTime = 0.0
		newDirTime = rng.randf_range(0.5, 2.0)
	
	if walkingEnabled:
		velocity = randomWalkDir
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
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
