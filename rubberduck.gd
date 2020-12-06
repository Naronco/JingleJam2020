extends KinematicBody

const AnimatedAxis = preload("res://AnimatedAxis.gd")

export (NodePath) var path
var move_speed = 100
var curve
var index = 0
var velocity = Vector3(0, 0, 0)
var waitingForDeparture = false
var acceleration = 0.5
var max_speed = 0.1

var targetX = AnimatedAxis.new()
var targetZ = AnimatedAxis.new()

signal arrived_at_port
signal leaving_port

func setup_animated_axis(axis):
	axis.speed = 2
	axis.stopDamping = 0.5

func _ready():
	if path:
		curve = get_node(path).curve
		targetX.value = transform.origin.x
		targetZ.value = transform.origin.z
		setup_animated_axis(targetX)
		setup_animated_axis(targetZ)
		targetX.move_to(curve.get_point_position(0).x)
		targetZ.move_to(curve.get_point_position(0).z)

func _physics_process(delta):
	if !path:
		return
	if $ContainerField.inUse:
		return
	if waitingForDeparture:
		emit_signal("leaving_port")
		waitingForDeparture = false
		index = wrapi(index + 1, 0, curve.get_point_count())

	var position = transform.origin
	if index == 0:
		if !targetX.moving && !targetZ.moving:
			emit_signal("arrived_at_port")
			$ContainerField.inUse = true
			waitingForDeparture = true
			velocity = Vector3(0, 0, 0)
			rotation = Vector3(0, 0, 0)
		else:
			targetX.value = transform.origin.x
			targetZ.value = transform.origin.z
			targetX.update(delta)
			targetZ.update(delta)
			velocity = Vector3(targetX.velocity, 0, targetZ.velocity)
			transform.origin += velocity
	else:
		var target = curve.get_point_position(index)
		target.y = transform.origin.y
		var d = target - transform.origin
		var dlen = d.length_squared()
		if dlen > 1:
			d *= 1.0 / sqrt(dlen)
		velocity += d * delta * acceleration
		if velocity.length_squared() > max_speed * max_speed:
			velocity = velocity.normalized() * max_speed
		velocity = velocity * pow(0.5, delta)
		targetX.velocity = velocity.x
		targetZ.velocity = velocity.z
		transform.origin += velocity
		
		if dlen < 0.1:
			index = wrapi(index + 1, 0, curve.get_point_count())

	if velocity.length_squared() / delta > 0.0001:
		look_at(transform.origin - velocity, Vector3(0, 1, 0))
