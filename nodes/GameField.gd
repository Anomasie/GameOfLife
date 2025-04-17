@tool
extends Control

const BORDER_CELL = Vector2i(1,0)

var game = GameOfLife.new()

var current_species = 0

# states
var marking = false
var deleting = false

@onready var Map = $Field/Map
@onready var WorldTime = $WorldTime

func _ready() -> void:
	# set scale
	var scale_factor = min(self.size.x/game.SIZE.x, self.size.y/game.SIZE.y)
	Map.scale = scale_factor * Vector2i(1,1)
	
	# load map
	load_map()

func _input(event):
	if event.is_action_pressed("scroll_down"):
		current_species -= 1
	if event.is_action_pressed("scroll_up"):
		current_species += 1
	if current_species < 0: current_species = len(game.species) - 1
	elif current_species >= len(game.species): current_species = 0

func _process(_delta: float) -> void:
	if marking or deleting:
		var mouse_pos_relative_unscaled = get_viewport().get_mouse_position() - Map.get_global_position()
		var mouse_pos_atlas = Vector2i(
			mouse_pos_relative_unscaled.x / Map.scale.x,
			mouse_pos_relative_unscaled.y / Map.scale.y
		)
		if mouse_pos_atlas.x >= 0 and mouse_pos_atlas.x < game.SIZE.x and mouse_pos_atlas.y >= 0 and mouse_pos_atlas.y < game.SIZE.y:
			if marking:
				game.map[mouse_pos_atlas.x][mouse_pos_atlas.y] = current_species
				Map.set_cell(Vector2i(mouse_pos_atlas.x, mouse_pos_atlas.y), 0, game.species[current_species]["atlas"])
			if deleting:
				game.map[mouse_pos_atlas.x][mouse_pos_atlas.y] = game.EMPTY
				Map.erase_cell(Vector2i(mouse_pos_atlas.x, mouse_pos_atlas.y))

# actions from GAME

## time

func set_pause(pause) -> void:
	if not pause:
		WorldTime.start()
	else:
		WorldTime.stop()

func set_time(value) -> void:
	WorldTime.wait_time = value

## deletion

func delete_all() -> void:
	set_map(game.empty_map())

# map generation & management

func load_map(map=game.random_map()) -> void:
	# delete everything
	Map.clear()
	
	# set frame
	for x in range(game.SIZE.x + 2):
		Map.set_cell(Vector2i(x-1,-1), 0, BORDER_CELL)
		Map.set_cell(Vector2i(x-1,game.SIZE.y), 0, BORDER_CELL)
	for y in range(game.SIZE.y):
		Map.set_cell(Vector2i(-1,y), 0, BORDER_CELL)
		Map.set_cell(Vector2i(game.SIZE.x,y), 0, BORDER_CELL)
	
	# set interior
	game.map = map
	set_map()

func read_map() -> void:
	for x in range(game.SIZE.x):
		var array = []
		array.resize(game.SIZE.y)
		for y in range(game.SIZE.y):
			var data = Map.get_cell_atlas_coords(Vector2i(x,y))
			array[y] = int(typeof(data) != TYPE_NIL and data == game.NORMAL_CELL) * 2
		game.map[x] = array

func set_map(new_map = game.map) -> void:
	game.set_map(new_map)
	for x in range(game.SIZE.x):
		for y in range(game.SIZE.y):
			if game.map[x][y] == game.EMPTY:
				Map.erase_cell(Vector2i(x,y))
			else:
				Map.set_cell(Vector2i(x,y), 0, game.species[game.map[x][y]]["atlas"])

func next_step() -> void:
	set_map(game.get_next_step())

func _on_world_time_timeout() -> void:
	next_step()

func print_matrix(mat=game.map) -> void:
	for x in len(mat):
		print(mat[x])

# background button & marking cells

func _on_background_button_button_down() -> void:
	if Input.is_action_pressed("add_cells"):
		if deleting: deleting = false
		else: marking = true
	if Input.is_action_pressed("delete_cells"):
		if marking: marking = false
		else: deleting = true

func _on_background_button_button_up() -> void:
	deleting = false
	marking = false
