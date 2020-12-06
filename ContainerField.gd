extends Spatial

export (int) var numRows
export (int) var containersPerRow
export (int) var stackHeight
export (int) var numGenerateContainers = 3

const Containerz = preload("res://Container.tscn")

const CONTAINER_WIDTH = 6.09
const CONTAINER_HEIGHT = 2.59
const CONTAINER_DEPTH = 2.44
const ROW_PADDING = 1.5
const COLUMN_PADDING = 5.0 / 16

class ContainerSpot:
	var index: int
	var position: Vector3
	var container = null
	
	func _init(i, pos, c):
		index = i
		position = pos
		container = c

# 1D array (numRows * containersPerRow) of stacks (last element = topmost)
var stacks = []
var random_indices = []

func _init():
	pass

func _ready():
	random_generate()

func random_generate():
	stacks.resize(numRows * containersPerRow)
	random_indices.resize(numRows * containersPerRow)
	for i in range(numRows * containersPerRow):
		random_indices[i] = i
		stacks[i] = []

	for i in range(numGenerateContainers):
		var spot = find_container_spot()
		if spot == null:
			break
		spot.container = Containerz.instance()
		add_child(spot.container)
		put_container(spot)

func get_pos(i: int, stackNum = 0):
	var column = i % containersPerRow
	var row = i / containersPerRow

	var x = (CONTAINER_DEPTH + ROW_PADDING) * numRows * -0.5 + ROW_PADDING + (CONTAINER_DEPTH + ROW_PADDING) * row
	var z = (CONTAINER_WIDTH + COLUMN_PADDING) * containersPerRow * -0.5 + ROW_PADDING + (CONTAINER_WIDTH + COLUMN_PADDING) * column
	
	return Vector3(x, stackNum * CONTAINER_HEIGHT, z)

func find_topmost_container():
	random_indices.shuffle()
	for i in random_indices:
		if stacks[i].size() > 0:
			return stacks[i][stacks[i].size() - 1]

	return null

func find_container_spot():
	random_indices.shuffle()
	for i in random_indices:
		if stacks[i].size() < stackHeight:
			return ContainerSpot.new(i, get_pos(i, stacks[i].size()), null)

	return null

func obtain(spot: ContainerSpot):
	if stacks[spot.index].size() == 0:
		return null
	return stacks[spot.index].pop_back()

func put_container(spot: ContainerSpot):
	if spot.container == null:
		return null

	spot.position = get_pos(spot.index, stacks[spot.index].size())
	spot.container.transform.origin = spot.position
	stacks[spot.index].append(spot)
	return spot
