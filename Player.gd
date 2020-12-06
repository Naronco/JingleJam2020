extends KinematicBody

const Paintball = preload("res://PaintBall/PaintBall.tscn")
onready var GlobalState = get_node("/root/GlobalState")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var jumpVel = 6.0
export(float) var walkingSpeed = 6.0
export(float) var mouseSensitivity = 0.002
export(float) var shootCooldown = 0.05;

var PLAYER_GRAVITY = Vector3(0, -9.8, 0)

const ACCEL = 16
const DEACCEL = 32

var SLERP_TIME = 0.5 # in seconds
var lastBasis
var basisSlerping = false
var basisSlerpTime = 0.0 # in seconds
var targetBasis

var velocity = Vector3(0, 0, 0)
var velocityBeforeJump = Vector3()

var rotationHelper
var camera

var shooting = false
var shootWait = 0.0

export(float) var crushCooldown = 0.25
export(int) var crushDmg = 2
var crushTime = 0.0
var wasCrushed = false

const MAX_HEALTH = 10
export(int) var health = MAX_HEALTH

# Actually equivalent to Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED right now.
var inGame = false

# Called when the node enters the scene tree for the first time.
func _ready():
	rotationHelper = $RotationHelper
	camera = $RotationHelper/Camera
	targetBasis = self.transform.basis
	
	get_tree().call_group("Enemies", "set_player", self)

# new_gravity IS NOT parallel to old_gravity
func _change_gravity(new_gravity):
	if basisSlerping:
		return
	
	var oldGravity = PLAYER_GRAVITY
	PLAYER_GRAVITY = new_gravity
	
	# TODO Use physics server gravity also for player.
	# PhysicsServer.area_set_param(get_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY_VECTOR, PLAYER_GRAVITY)
	
	# Assume oldGravity and newGravity DO NOT POINT IN THE SAME DIRECTION
	var rotAxis = oldGravity.cross(PLAYER_GRAVITY).normalized()
	var rotAngle = acos(oldGravity.normalized().dot(PLAYER_GRAVITY.normalized()))

	# Rotate basis
	lastBasis = transform.basis
	targetBasis = transform.basis.rotated(rotAxis, rotAngle)
	basisSlerping = true
	basisSlerpTime = 0.0

# g -> -g
func flip_gravity():
	if basisSlerping:
		return

	var oldGravity = PLAYER_GRAVITY
	PLAYER_GRAVITY = -PLAYER_GRAVITY
	
	# TODO Use physics server gravity also for player.
	# PhysicsServer.area_set_param(get_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY_VECTOR, PLAYER_GRAVITY)
	
	# In this case, the cross product of old_gravity and new_gravity is zero, so we have to (arbitrarily) pick an axis of rotation and rotate about 180 deg
	var up = -PLAYER_GRAVITY.normalized()
	var right = rotationHelper.get_global_transform().basis.x # Always perpendicular to up
	var rotAxis = up.cross(right).normalized() # Actually, cross(up, right) should already be normalized
	var rotAngle = PI
	
	lastBasis = transform.basis
	targetBasis = transform.basis.rotated(rotAxis, rotAngle)
	basisSlerping = true
	basisSlerpTime = 0.0

func do_damage(source, dmg):
	health -= dmg
	if health > 10:
		health = 10
	elif health <= 0:
		health = 0

	var healthBar = get_parent().find_node("GUI").find_node("HealthBar")
	healthBar.set_health(health)

func collect_present(source):
	GlobalState.presents += 1

func collect_cat(source):
	GlobalState.cats += 1

func _physics_process(delta):
	# check out of bounds
	if global_transform.origin.y > 70 or global_transform.origin.y < -10:
		do_damage(null, MAX_HEALTH)

	if health <= 0:
		if $RotationHelper/Camera.transform.origin.y > 0.1:
			$RotationHelper/Camera.transform.origin.y -= delta
		else:
			$RotationHelper/Camera.transform.origin.y = 0.1
		return
	
	# Player walk direction in global space
	var walkingDir = Vector3()
	
	# Plane of player movement defined by basis of 
	var globalTransform = rotationHelper.get_global_transform()
	
	# (x,y) coordinates in player movement plane
	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
	if Input.is_action_pressed("win") && GlobalState.presents >= GlobalState.numPresents - 1:
		get_tree().change_scene("res://Win.tscn")
		return

	if basisSlerping:
		basisSlerpTime += delta
		if basisSlerpTime >= SLERP_TIME:
			basisSlerpTime = SLERP_TIME
			basisSlerping = false

		transform.basis = lastBasis.slerp(targetBasis, basisSlerpTime / SLERP_TIME)

	input_movement_vector = input_movement_vector.normalized()
	
	# Transform (x,y) player movement plane into global space
	walkingDir -= globalTransform.basis.z * input_movement_vector.y
	walkingDir += globalTransform.basis.x * input_movement_vector.x
	# walkingDir should be normalized still
	
	# Project walking direction onto the plane perpendicular to gravity
	var up = -PLAYER_GRAVITY.normalized()
	walkingDir -= up.dot(walkingDir) * up
	walkingDir = walkingDir.normalized()

	var airFrictionCoeff = 1.3
	
	if is_on_floor():
		# target is perpendicular to gravity
		var target = walkingSpeed * walkingDir
		# Walk regularly
		# Set velocity into walking dir, but leave component along gravity untouched.
		
		var upVel = velocity.dot(up) * up
		var planeVel = velocity - upVel

		var accel
		if walkingDir.dot(planeVel) > 0:
			accel = ACCEL
		else:
			accel = DEACCEL

		planeVel = planeVel.linear_interpolate(target, accel * delta)
		velocity = planeVel + upVel
	else:
		var airAccel = 10
		# Treat movement input from user as force change, not as velocity, when not on floor
		var upVel = velocity.dot(up) * up
		var planeVel = velocity - upVel
		velocity = upVel + (planeVel - airFrictionCoeff * planeVel * delta + walkingDir * delta * airAccel)

	var upVel = velocity.dot(up) * up
	velocity += (PLAYER_GRAVITY - upVel * airFrictionCoeff * 0.3) * delta 

	if is_on_floor():
		velocityBeforeJump = Vector3()

		if Input.is_action_just_pressed('movement_jump'):
			var velInPlane = (velocity - velocity.dot(up) * up)
			velocityBeforeJump = velInPlane
			velocity = up * jumpVel + velInPlane
	
	velocity = move_and_slide(velocity, up)
	
	var push = 0.1
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.get_collider().name == "Enemy":
			print(collision.get_collider().velocity)
			collision.get_collider().velocity += -collision.normal * 2
		if collision.collider.has_method("apply_central_impulse"):
			# print("Pushing")
			collision.collider.apply_central_impulse(-collision.normal * velocity.length() * push)
	
	if not wasCrushed:
		for i in get_slide_count():
			var ci = get_slide_collision(i)
			for j in i:
				var cj = get_slide_collision(j)
				
				# Assume that ci.normal and cj.normal are properly normalized
				var d = ci.normal.dot(cj.normal)

				var bothHeavy = is_heavy(ci.collider) and is_heavy(cj.collider)

				var threshold = -0.9
				if d < threshold and bothHeavy:
					print("CRUSH!")
					wasCrushed = true
					# do_damage(ci.collider, crushDmg)
	else:
		crushTime += delta
		if crushTime >= crushCooldown:
			crushTime = 0.0
			wasCrushed = false

func knockback(vec):
	var up = -PLAYER_GRAVITY.normalized()
	velocity = velocity.dot(up) * up + (velocity - velocity.dot(up) * up + vec - vec.dot(up) * up)

func is_heavy(collider):
	if collider.get_class() == "StaticBody":
		return true
	if collider.get_class() == "RigidBody":
		if collider.mass > 10 or collider.mode == RigidBody.MODE_STATIC:
			return true
	return false

func shoot():
	var up = -PLAYER_GRAVITY.normalized()
	var paintball = Paintball.instance()
	paintball.gravity = PLAYER_GRAVITY
	paintball.direction = -camera.global_transform.basis.z
	paintball.global_transform.origin = $RotationHelper/Camera/gun.global_transform.origin + camera.global_transform.basis.y * 0.1
	get_parent().add_child(paintball)
	add_collision_exception_with(paintball)
	shootWait = shootCooldown

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if !inGame:
			print("Mouse Click/Unclick at: ", event.position)
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				inGame = true
		else:
			if event.button_index == BUTTON_LEFT:
				shooting = event.pressed
	elif event is InputEventMouseMotion:
		if inGame && health > 0:
			camera.rotate_x(-event.relative.y * mouseSensitivity)
			rotationHelper.rotate_y(-event.relative.x * mouseSensitivity)
			var cam_rot = camera.rotation_degrees
			cam_rot.x = clamp(cam_rot.x, -87.5, 87.5)
			cam_rot.y = 0
			cam_rot.z = 0
			camera.rotation_degrees = cam_rot

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			inGame = false

	if health <= 0:
		return

	if shooting:
		if shootWait > 0:
			shootWait -= delta
		else:
			shoot()
