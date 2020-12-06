extends KinematicBody

export(float) var jumpFreq = 5.0
export(float) var jumpVel = 5.0

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
	
	var gravityDir = PhysicsServer.area_get_param(get_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY_VECTOR)
	var gravityStrength = PhysicsServer.area_get_param(get_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY)
	
	var up = -gravityDir.normalized()
	var velUp = velocity.dot(up) * up
	var velPlane = velocity - velUp
	
	if lastWalkDirChangeTime >= newDirTime:
		var angle = rng.randf_range(0, 2 * PI)
		randomWalkDir = Vector3(cos(angle), 0, sin(angle)) * rng.randf_range(0.5, 2) * 2
		lastWalkDirChangeTime = 0.0
		newDirTime = rng.randf_range(0.5, 2.0)
		
		if rng.randi_range(0, 2) == 0:
			# jump
			velUp = up * jumpVel

	# Assume randomWalkDir is parallel to gravity
	velUp += gravityDir * gravityStrength * delta
	velPlane += randomWalkDir * delta - 2 * velPlane * delta
	velocity = velUp + velPlane
	velocity = move_and_slide(velocity, up)


func set_player(p):
	player = p
