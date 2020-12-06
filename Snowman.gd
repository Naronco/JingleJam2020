extends KinematicBody

export(float) var throwFrequency = 5.0
export(bool) var walkingEnabled = false
export(float) var walkingSpeedMin = 0.2
export(float) var walkingSpeedMax = 1.0

const COLLAPSE_TIME = 2.0

var lastThrowTime = 0.0
var throwCount = 0
var player

var rng = RandomNumberGenerator.new()

var randomWalkDir = Vector3()
var lastWalkDirChangeTime = 0.0
var newDirTime = rng.randf_range(0.5, 2.0)

var velocity = Vector3()

var collapsed = false
var collapseTime = 0.0
var collapsedSnowman = null

const Snowball = preload("res://Snowball.tscn")
const CollapsedSnowman = preload("res://CollapsedSnowman.tscn")

func _ready():
	rng.randomize()
	lastThrowTime = rng.randf_range(-1, 0)

func _physics_process(delta):
	if collapsed:
		collapseTime -= delta
		if collapseTime <= 0:
			remove_child(collapsedSnowman)
			collapsedSnowman = null
			
			collapseTime = 0
			collapsed = false
			
			$CollisionShape.disabled = false
			$AnimatedSprite3D.visible = true
			
			lastThrowTime = rng.randf_range(-2, -1)
			lastWalkDirChangeTime = 0.0
		return
	
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

func hit_by_paintball(paintball):
	collapse()

func collapse():
	if collapsed:
		return
	collapsed = true
	collapseTime = COLLAPSE_TIME
	
	$CollisionShape.disabled = true
	$AnimatedSprite3D.visible = false
	
	collapsedSnowman = CollapsedSnowman.instance()
	
	var headRandDir = Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.5, 0.5), rng.randf_range(-1, 1)) * 3.0
	var upperBodyRandDir = Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.5, 0.5), rng.randf_range(-1, 1)) * 3.0
	var lowerBodyRandDir = Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.5, 0.5), rng.randf_range(-1, 1)) * 3.0
	
	add_child(collapsedSnowman)
	
	collapsedSnowman.get_node("Head").apply_central_impulse(headRandDir)
	collapsedSnowman.get_node("UpperBody").apply_central_impulse(upperBodyRandDir)
	collapsedSnowman.get_node("LowerBody").apply_central_impulse(lowerBodyRandDir)

func set_player(p):
	player = p
