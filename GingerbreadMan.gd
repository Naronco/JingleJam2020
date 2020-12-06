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

var attacked = false
var attackCooldown = 0.0

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
	
	var playerInRange = false
	if player != null:
		var d2 = (player.global_transform.origin - global_transform.origin).length_squared()
		playerInRange = d2 < 8 * 8
	
	if lastWalkDirChangeTime >= newDirTime:
		if rng.randi_range(0, 5) == 0: # walk in random direction
			var angle = rng.randf_range(0, 2 * PI)
			randomWalkDir = Vector3(cos(angle), 0, sin(angle)) * rng.randf_range(0.5, 2) * 5
		elif player != null and playerInRange:
			var playerDir = player.global_transform.origin - global_transform.origin
			randomWalkDir = playerDir - playerDir.y * Vector3(0, 1, 0)
			if randomWalkDir.length_squared() > 1:
				randomWalkDir = randomWalkDir.normalized()
			randomWalkDir *= rng.randf_range(5, 9)
		else:
			randomWalkDir = Vector3(0, 0, 0)
		
		lastWalkDirChangeTime = 0.0
		newDirTime = rng.randf_range(0.5, 2.0)

	# Assume randomWalkDir is parallel to gravity
	velUp += gravityDir * gravityStrength * delta
	velPlane += randomWalkDir * delta - 2 * velPlane * delta
	
	if not attacked:
		for index in get_slide_count():
			var collision = get_slide_collision(index)
			if collision.collider.get_name() == "Player":
				collision.collider.do_damage(self, 1)
				attacked = true
				attackCooldown = 1.0
				velUp = up * jumpVel
				lastWalkDirChangeTime = 0.0
				velPlane = collision.normal * 5
				collision.collider.knockback(-collision.normal * 15)
	else:
		attackCooldown -= delta
		if attackCooldown <= 0:
			attacked = false
			attackCooldown = 0.0
	
	velocity = velUp + velPlane
	velocity = move_and_slide(velocity, up)

func hit_by_paintball(paintball):
	queue_free()


func set_player(p):
	player = p
