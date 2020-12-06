extends Object

const max_velocity = 0.1

var value = 0.0
var velocity = 0.0
var target_velocity = 0.0
var target = 0.0
var moving = false
var speed = 1.0
var stopDamping = 0.97
var startDamping = 0.7

signal done

func _init(initValue = 0.0):
	value = initValue

func move_to(t):
	target = t
	moving = true

func update(delta):
	if moving:
		if target > value:
			target_velocity = max_velocity * speed
		else:
			target_velocity = -max_velocity * speed

		var dist = pow(speed, 3)
		if abs(target - value) < 3 * dist:
			var small_target = target_velocity * max(0.1, (abs(target - value) / (3 * dist)) * 0.1)
			velocity = (velocity - small_target) * pow(1 - stopDamping, delta) + small_target
		else:
			if abs(velocity - target_velocity) > 0.001:
				velocity = (velocity - target_velocity) * pow(1 - startDamping, delta) + target_velocity

		value += velocity
		if abs(target - value) < 0.005 * speed and abs(velocity) < 0.1 * speed:
			moving = false
			velocity = 0
			emit_signal("done", self)

	return value
