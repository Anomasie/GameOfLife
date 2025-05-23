extends Node
class_name GameOfLife

var SIZE = Vector2i(40,25)

const EMPTY = -1
const FULL_ARRAY = [0,1,2,3,4,5,6,7,8]

const NEIGHBORS = [
		Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1),
		Vector2i(-1, 0), Vector2i(1,0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)
	]

var SPECIES = []

var KEY_DICT = {}

func _init(size=Vector2i(40,25), species=[Species.new()]):
	SIZE = size
	SPECIES = species

# calculate maps

func set_key_dict() -> void:
	for i in len(SPECIES):
		KEY_DICT[SPECIES[i].my_name] = i

func get_color_dict() -> Dictionary:
	var dict = {}
	for species in SPECIES:
		dict[species.name] = species.color
	return dict

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
				if randf() <= SPECIES[i].chance:
					array[y] = i
		result.append(array)
	return result

func fulfills(map, requirements, x,y) -> bool:
	if len(map) != SIZE.x or (len(map) > 0 and len(map[0]) != SIZE.y):
		print("ERROR in game_of_life.gd: map size (", len(map),", ",len(map[0]), ") and game size (", SIZE, ") do not agree")
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
		if requirements.has(SPECIES[i].my_name) and sum not in requirements[SPECIES[i].my_name]:
			return false
		else:
			all_sums += sum
	# sum requirement
	if not requirements.has("sum") or all_sums in requirements["sum"]:
		return true
	else:
		return false

func get_next_step(map) -> Array:
	if len(KEY_DICT.keys()) == 0:
		set_key_dict()
	
	var new_map = map.duplicate()
	for x in range(SIZE.x):
		var array = map[x].duplicate()
		for y in range(SIZE.y):
			# check if species survives
			if array[y] != EMPTY:
				if not fulfills(map, SPECIES[map[x][y]].survival, x,y):
					array[y] = EMPTY
			# if empty: check if specise spreads to there
			if array[y] == EMPTY:
				for i in len(SPECIES):
					if array[y] == EMPTY:
						if fulfills(map, SPECIES[i].reproduction, x,y):
							array[y] = i
		new_map[x] = array
	return new_map

# operate with variables

func set_size(new_size) -> void:
	SIZE = new_size

func add_species(new) -> void:
	# add species in each requirement
	for species in SPECIES:
		species.survival[new.my_name] = FULL_ARRAY
		species.reproduction[new.my_name] = FULL_ARRAY
		new.survival[species.my_name] = FULL_ARRAY
		new.reproduction[species.my_name] = FULL_ARRAY
	# add new species
	SPECIES.append(new)

func remove_species(index) -> void:
	# save name
	var its_name = SPECIES[index].my_name
	# remove species
	SPECIES.remove_at(index)
	# remove species requirement in each remaining species
	for species in SPECIES:
		species.survival.erase(its_name)
		species.reproduction.erase(its_name)

# help functions

func print_matrix(mat) -> void:
	for x in len(mat):
		print(mat[x])
