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
var hooked_offset = Vector3(0, 0, 0)

func _physics_process(delta):
	var x = extension_axis.update(delta)
	var y = vertical_axis.update(delta)
	var z = sideways_axis.update(delta)
	$KinematicBody.transform.origin = Vector3(0, 0, z)
	$KinematicBody/Picker.transform.origin = Vector3(x, y, 0)
	$KinematicBody/Seat.transform.origin = Vector3(x, 0, 0)
	$KinematicBody/PlayerDropArea.transform.origin = Vector3(x, 0, 0)

	if hooked != null:
		hooked.transform.origin = Vector3(x, y, z) - hooked_offset

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

func _pickup(picker, from, offset = Vector3(0, 0, 0)):
	if from == null || from.container == null:
		vertical_axis.move_to(IDLE_HEIGHT)
		if vertical_axis.moving:
			yield(vertical_axis, "done")
		return null

	from.position += offset

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
	from.position += offset

	if from == null || from.container == null:
		vertical_axis.move_to(IDLE_HEIGHT)
		if vertical_axis.moving:
			yield(vertical_axis, "done")
		return null

	hooked = from.container
	hooked.mode = RigidBody.MODE_KINEMATIC
	hooked_offset = offset

	vertical_axis.move_to(IDLE_HEIGHT)
	if vertical_axis.moving:
		yield(vertical_axis, "done")

	return from

func _deposit(deposit, put, offset = Vector3(0, 0, 0)):
	if hooked == null:
		return

	put.position += offset

	sideways_axis.move_to(put.position.z)
	extension_axis.move_to(put.position.x)
	if sideways_axis.moving:
		yield(sideways_axis, "done")
	if extension_axis.moving:
		yield(extension_axis, "done")

	if hooked == null:
		return

	vertical_axis.move_to(put.position.y)
	if vertical_axis.moving:
		yield(vertical_axis, "done")

	if hooked == null:
		vertical_axis.move_to(IDLE_HEIGHT)
		if vertical_axis.moving:
			yield(vertical_axis, "done")
		return

	put.container = hooked
	deposit.put_container(put)
	hooked.mode = RigidBody.MODE_STATIC
	hooked = null
	hooked_offset = Vector3(0, 0, 0)
	yield(random_idle(), "timeout")

	vertical_axis.move_to(IDLE_HEIGHT)
	if vertical_axis.moving:
		yield(vertical_axis, "done")

func _animate():
	if pickupField == null:
		yield(get_tree().create_timer(5), "timeout")
		return

	# ContainerField
	var picker = get_node(pickupField)
	var deposit = get_node(depositField)
	
	if picker == null:
		yield(get_tree().create_timer(5), "timeout")
		return

	var offset = picker.global_transform.origin - deposit.global_transform.origin

	# (index, position, container)
	var from = picker.find_topmost_container()

	# (x, y, z) = (extension, vertical, sideways)

	#  0) pick random + crane down
	#  1) hold / pickup
	#  2) crane up + deposit random
	yield(_pickup(picker, from, offset), "completed")
	if hooked == null:
		return

	#  3) crane forward + crane down
	#  4) hold / unload
	#  5) crane up + pick random
	var put = deposit.find_container_spot()
	yield(_deposit(deposit, put), "completed")

	#  6) crane down
	#  7) hold / pickup
	from = deposit.find_topmost_container()
	yield(_pickup(deposit, from), "completed")
	if hooked == null:
		return

	#  8) crane up + crane backward
	#  9) deposit random
	put = picker.find_container_spot()
	yield(_deposit(picker, put, offset), "completed")



func _on_PlayerDropArea_body_entered(body):
	if body.get_name() == "Player" and hooked != null and vertical_axis.value > 3 and randf() < 0.4:
		hooked.mode = RigidBody.MODE_RIGID
		hooked = null
		hooked_offset = Vector3(0, 0, 0)
