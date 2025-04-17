@tool
extends Control

var game = GameOfLife.new()

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

func _process(_delta: float) -> void:
	if marking or deleting:
		var mouse_pos_relative_unscaled = get_viewport().get_mouse_position() - Map.get_global_position()
		var mouse_pos_atlas = Vector2i(
			mouse_pos_relative_unscaled.x / Map.scale.x,
			mouse_pos_relative_unscaled.y / Map.scale.y
		)
		if mouse_pos_atlas.x >= 0 and mouse_pos_atlas.x < game.SIZE.x and mouse_pos_atlas.y >= 0 and mouse_pos_atlas.y < game.SIZE.y:
			if marking:
				game.map[mouse_pos_atlas.x][mouse_pos_atlas.y] = 1
				Map.set_cell(Vector2i(mouse_pos_atlas.x, mouse_pos_atlas.y), 0, game.NORMAL_CELL)
			if deleting:
				game.map[mouse_pos_atlas.x][mouse_pos_atlas.y] = 0
				Map.erase_cell(Vector2i(mouse_pos_atlas.x, mouse_pos_atlas.y))

# actions from GAME

## time

func set_pause(resume) -> void:
	if resume:
		WorldTime.start()
	else:
		WorldTime.stop()

## deletion

func delete_all() -> void:
	set_map(game.empty_map())

# map generation & management

func load_map(map=game.random_map()) -> void:
	# delete everything
	Map.clear()
	
	# set frame
	for x in range(game.SIZE.x + 2):
		Map.set_cell(Vector2i(x-1,-1), 0, game.BORDER_CELL)
		Map.set_cell(Vector2i(x-1,game.SIZE.y), 0, game.BORDER_CELL)
	for y in range(game.SIZE.y):
		Map.set_cell(Vector2i(-1,y), 0, game.BORDER_CELL)
		Map.set_cell(Vector2i(game.SIZE.x,y), 0, game.BORDER_CELL)
	
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
			match game.map[x][y]:
				3:
					Map.set_cell(Vector2i(x,y), 0, game.FULL_CELL)
				2:
					Map.set_cell(Vector2i(x,y), 0, game.NORMAL_CELL)
				1:
					Map.set_cell(Vector2i(x,y), 0, game.NEW_CELL)
				_:
					Map.erase_cell(Vector2i(x,y))

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
