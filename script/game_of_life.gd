extends Node
class_name GameOfLife

var SIZE: Vector2i

const NORMAL_CELL = Vector2i(0,0)
const BORDER_CELL = Vector2i(1,0)
const NEW_CELL = Vector2i(1,1)
const FULL_CELL = Vector2i(0,1)

const EMPTY = -1

const NEIGHBORS = [
		Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1),
		Vector2i(-1, 0), Vector2i(1,0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)
	]

var SPECIES = []

const std_species = [
	{
		"name": "Conway",
		"color": Color.WHITE,
		"chance": 0.16,
		"reproduction": {
			"sum": [3],
		},
		"survival": {
			"sum": [2,3]
		}
	}
]

const old_species = [
	{
		"name": "plants",
		"color": Color.GREEN,
		"chance": 0.1,
		"reproduction": {
			"plancton": [0,1],
			"plants": [1,2]
		},
		"survival": {
			"plancton": [0,1],
			"plants": [0,1,2,3,4,5,6]
		}
	},
	{
		"name": "plancton",
		"color": Color.BLUE,
		"chance": 0.13,
		"reproduction": {
			"plants": [3,4,5,6,7,8],
			"plancton": [1,2,3],
			"predator": [0,1]
		},
		"survival": {
			"predator": [0,1,2,3],
			"plants": [1,2,3,4,5,6,7,8],
			"plancton": [1,2,3,4]
		}
	},
	{
		"name": "predator",
		"color": Color.RED,
		"chance": 0.1,
		"reproduction": {
			"predator": [1,2],
			"plancton": [1,2,3,4,5,6,7,8]
		},
		"survival": {
			"plancton": [1,2,3,4,5,6,7,8],
			"predator": [0,1,2]
		}
	}
]

var KEY_DICT = {}

var map = random_map()

func _init(size=Vector2i(80,50), species=std_species):
	SIZE = size
	SPECIES = species
	map = empty_map()

# calculate maps

func set_key_dict():
	for i in len(SPECIES):
		KEY_DICT[SPECIES[i]["name"]] = i

func empty_map() -> Array:
	var array = []
	array.resize(SIZE.y)
	array.fill(EMPTY)
	var result = []
	for x in SIZE.x:
		result.append(array.duplicate())
	return result

func random_map() -> Array:
	var result = []
	for x in SIZE.x:
		var array = []
		array.resize(SIZE.y)
		array.fill(EMPTY)
		for y in SIZE.y:
			for i in len(SPECIES):
				if randf() <= SPECIES[i]["chance"]:
					array[y] = i
		result.append(array)
	return result

func fulfills(requirements, x,y):
	# species cannot survive
	if not SPECIES[map[x][y]].has("survival"):
		return false
	# not sum requirements
	var all_sums = 0
	for i in len(SPECIES):
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
			sum += int(map[a][b] == i)
		## check conditions
		if requirements.has(SPECIES[i]["name"]) and sum not in requirements[SPECIES[i]["name"]]:
			return false
		else:
			all_sums += sum
	# sum requirement
	if not requirements.has("sum") or all_sums in requirements["sum"]:
		return true
	else:
		return false

func get_next_step() -> Array:
	if len(KEY_DICT.keys()) == 0:
		set_key_dict()
	
	var new_map = map.duplicate()
	for x in range(SIZE.x):
		var array = map[x].duplicate()
		for y in range(SIZE.y):
			# check if species survives
			if array[y] != EMPTY:
				if not SPECIES[map[x][y]].has("survival") or not fulfills(SPECIES[map[x][y]]["survival"], x,y):
					array[y] = EMPTY
			# if empty: check if specise spreads to there
			if array[y] == EMPTY:
				for i in len(SPECIES):
					if array[y] == EMPTY:
						if SPECIES[i].has("reproduction") and fulfills(SPECIES[i]["reproduction"], x,y):
							array[y] = i
		new_map[x] = array
	return new_map

# operate with variables

func set_size(new_size) -> void:
	SIZE = new_size
	map = random_map()

func set_map(new_map) -> void:
	map = new_map

# help functions

func print_matrix(mat=map) -> void:
	for x in len(mat):
		print(mat[x])
