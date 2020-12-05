extends Spatial

const AnimatedAxis = preload("res://AnimatedAxis.gd")

export (NodePath) var pickupField
export (NodePath) var depositField

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	_loop()

var sideways_axis = AnimatedAxis.new()
var vertical_axis = AnimatedAxis.new(IDLE_HEIGHT)
var extension_axis = AnimatedAxis.new()
var hooked = null

func _physics_process(delta):
	var x = extension_axis.update(delta)
	var y = vertical_axis.update(delta)
	var z = sideways_axis.update(delta)
	$KinematicBody.transform.origin = Vector3(0, 0, z)
	$KinematicBody/Picker.transform.origin = Vector3(x, y + 2.59, 0)

	if hooked != null:
		hooked.transform.origin = Vector3(x, y, z)

const IDLE_MIN_S = 0.250
const IDLE_MAX_S = 2.5
const IDLE_HEIGHT = 15

func random_idle():
	return get_tree().create_timer(rand_range(IDLE_MIN_S, IDLE_MAX_S))

func _loop():
	while true:
		yield(_animate(), "completed")
		yield(random_idle(), "timeout")

func find_land_container():
	pass

func find_land_deposit():
	pass

func find_ship_container():
	pass

func find_ship_deposit():
	pass

func _pickup(picker, from):
	extension_axis.move_to(from.position.x)
	sideways_axis.move_to(from.position.z)
	if extension_axis.moving:
		yield(extension_axis, "done")
	if sideways_axis.moving:
		yield(sideways_axis, "done")

	vertical_axis.move_to(from.position.y)
	if vertical_axis.moving:
		yield(vertical_axis, "done")

	yield(random_idle(), "timeout")
	from = picker.obtain(from)
	if from == null || from.container == null:
		vertical_axis.move_to(IDLE_HEIGHT)
		if vertical_axis.moving:
			yield(vertical_axis, "done")
		return null

	hooked = from.container

	vertical_axis.move_to(IDLE_HEIGHT)
	if vertical_axis.moving:
		yield(vertical_axis, "done")

	return from

func _deposit(deposit, put):
	if hooked == null:
		return

	sideways_axis.move_to(put.position.z)
	extension_axis.move_to(put.position.x)
	if sideways_axis.moving:
		yield(sideways_axis, "done")

	vertical_axis.move_to(put.position.y)
	if extension_axis.moving:
		yield(extension_axis, "done")
	if vertical_axis.moving:
		yield(vertical_axis, "done")

	put.container = hooked
	deposit.put_container(put)
	yield(random_idle(), "timeout")
	hooked = null

	vertical_axis.move_to(IDLE_HEIGHT)
	if vertical_axis.moving:
		yield(vertical_axis, "done")

func _animate():
	# ContainerField
	var picker = get_node(pickupField)
	var deposit = get_node(depositField)

	# (index, position, container)
	var from = picker.find_topmost_container()

	# (x, y, z) = (extension, vertical, sideways)

	#  0) pick random + crane down
	#  1) hold / pickup
	#  2) crane up + deposit random
	yield(_pickup(picker, from), "completed")

	#  3) crane forward + crane down
	#  4) hold / unload
	#  5) crane up + pick random
	var put = deposit.find_container_spot()
	yield(_deposit(deposit, put), "completed")

	#  6) crane down
	#  7) hold / pickup
	from = deposit.find_topmost_container()
	yield(_pickup(deposit, from), "completed")

	#  8) crane up + crane backward
	#  9) deposit random
	put = picker.find_container_spot()
	yield(_deposit(picker, put), "completed")

