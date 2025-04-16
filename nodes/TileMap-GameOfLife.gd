@tool
extends Control

@export var SIZE = Vector2i(50,32)

const NORMAL_CELL = Vector2i(0,0)
const BORDER_CELL = Vector2i(1,0)
const NEW_CELL = Vector2i(1,1)
const FULL_CELL = Vector2i(0,1)

const NEIGHBORS = [
		Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1),
		Vector2i(-1, 0), Vector2i(1,0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)
	]

var matrix = []

# states
var marking = false

@onready var Map = $Field/Map
@onready var WorldTime = $WorldTime

func _ready() -> void:
	# set scale
	var scale_factor = min(self.size.x/SIZE.x, self.size.y/SIZE.y)
	Map.scale = scale_factor * Vector2i(1,1)
	
	# define matrix
	matrix = random_map()
	# load map
	load_map()

func _process(_delta: float) -> void:
	if marking:
		var mouse_pos_relative_unscaled = get_viewport().get_mouse_position() - Map.get_global_position()
		var mouse_pos_atlas = Vector2i(
			mouse_pos_relative_unscaled.x / Map.scale.x,
			mouse_pos_relative_unscaled.y / Map.scale.y
		)
		if mouse_pos_atlas.x >= 0 and mouse_pos_atlas.x < SIZE.x and mouse_pos_atlas.y >= 0 and mouse_pos_atlas.y < SIZE.y:
			matrix[mouse_pos_atlas.x][mouse_pos_atlas.y] = 1
			Map.set_cell(Vector2i(mouse_pos_atlas.x,mouse_pos_atlas.y), 0, NORMAL_CELL)

# actions from GAME

## time

func set_pause(resume) -> void:
	if resume:
		WorldTime.start()
	else:
		WorldTime.stop()

## deletion

func delete_all() -> void:
	set_map(empty_map())

# map generation & management

func empty_map() -> Array:
	var array = []
	array.resize(SIZE.y)
	array.fill(0)
	var result = []
	result.resize(SIZE.x)
	result.fill(array)
	return result

func random_map(chance = 0.16) -> Array:
	var result = []
	for x in SIZE.x:
		var array = []
		for y in SIZE.y:
			array.append( int(
				randf() <= chance
			) )
		result.append(array)
	return result

func load_map(map=random_map()) -> void:
	# delete everything
	Map.clear()
	
	# set frame
	for x in range(SIZE.x + 2):
		Map.set_cell(Vector2i(x-1,-1), 0, BORDER_CELL)
		Map.set_cell(Vector2i(x-1,SIZE.y), 0, BORDER_CELL)
	for y in range(SIZE.y):
		Map.set_cell(Vector2i(-1,y), 0, BORDER_CELL)
		Map.set_cell(Vector2i(SIZE.x,y), 0, BORDER_CELL)
	
	# set interior
	matrix = map
	set_map()

func read_map() -> void:
	for x in range(SIZE.x):
		var array = []
		array.resize(SIZE.y)
		for y in range(SIZE.y):
			var data = Map.get_cell_atlas_coords(Vector2i(x,y))
			array[y] = int(typeof(data) != TYPE_NIL and data == NORMAL_CELL) * 2
		matrix[x] = array

func set_map(new_map = matrix) -> void:
	matrix = new_map
	for x in range(SIZE.x):
		for y in range(SIZE.y):
			match matrix[x][y]:
				3:
					Map.set_cell(Vector2i(x,y), 0, FULL_CELL)
				2:
					Map.set_cell(Vector2i(x,y), 0, NORMAL_CELL)
				1:
					Map.set_cell(Vector2i(x,y), 0, NEW_CELL)
				_:
					Map.erase_cell(Vector2i(x,y))

func next_step() -> void:
	var new_matrix = matrix.duplicate()
	for x in range(SIZE.x):
		var array = matrix[x].duplicate()
		for y in range(SIZE.y):
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
				sum += int(matrix[a][b] != 0)
			if sum == 3:
				if matrix[x][y] != 0:
					array[y] = 3
				else:
					array[y] = 1
			elif sum == 2 and matrix[x][y] != 0:
				array[y] = 2
			else:
				array[y] = 0
		new_matrix[x] = array
	set_map(new_matrix.duplicate())

func _on_world_time_timeout() -> void:
	next_step()

func print_matrix(mat=matrix) -> void:
	for x in len(mat):
		print(mat[x])

# background button & marking cells

func _on_background_button_button_down() -> void:
	marking = true

func _on_background_button_button_up() -> void:
	marking = false
