extends Node
class_name GameOfLife

const SIZE = Vector2i(100,50)

const NORMAL_CELL = Vector2i(0,0)
const BORDER_CELL = Vector2i(1,0)
const NEW_CELL = Vector2i(1,1)
const FULL_CELL = Vector2i(0,1)

const NEIGHBORS = [
		Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1),
		Vector2i(-1, 0), Vector2i(1,0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)
	]

var map = random_map()

# calculate maps

static func empty_map() -> Array:
	var array = []
	array.resize(SIZE.y)
	array.fill(0)
	var result = []
	result.resize(SIZE.x)
	result.fill(array)
	return result

static func random_map(chance = 0.16) -> Array:
	var result = []
	for x in SIZE.x:
		var array = []
		for y in SIZE.y:
			array.append( int(
				randf() <= chance
			) )
		result.append(array)
	return result

func get_next_step() -> Array:
	var new_map = map.duplicate()
	for x in range(SIZE.x):
		var array = map[x].duplicate()
		for y in range(SIZE.y):
			# sum requirement
			## read the room
			var sum = 0
			for vector in NEIGHBORS:
				var a = x + vector.x
				var b = y + vector.y
				if a < 0:
					a = SIZE.x-1
				elif a >= SIZE.x:
					a = 0
				if b < 0:
					b = SIZE.y-1
				elif b >= SIZE.y:
					b = 0
				sum += int(map[a][b] != 0)
			## check conditions
			if sum == 3:
				if map[x][y] != 0:
					array[y] = 3
				else:
					array[y] = 1
			elif sum == 2 and map[x][y] != 0:
				array[y] = 2
			else:
				array[y] = 0
		new_map[x] = array
	return new_map

# operate with variables

func set_map(new_map) -> void:
	map = new_map

# help functions

func print_matrix(mat=map) -> void:
	for x in len(mat):
		print(mat[x])
