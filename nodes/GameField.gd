@tool
extends MarginContainer

const BORDER_CELL = Vector2i(1,0)

var game = GameOfLife.new()
var current_species = 0

# states
var marking = false
var deleting = false

@onready var Map = $Margin/Field/Map
@onready var Field = $Margin/Field
@onready var WorldTime = $WorldTime

@onready var Margin = $Margin
@onready var Background = $Background

func _ready() -> void:
	# load map
	load_map()
	await get_tree().process_frame
	self.resize()

func _input(event):
	if event.is_action_pressed("scroll_down"):
		current_species -= 1
	if event.is_action_pressed("scroll_up"):
		current_species += 1
	if current_species < 0: current_species = len(game.SPECIES) - 1
	elif current_species >= len(game.SPECIES): current_species = 0

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
				Map.set_cell(Vector2i(mouse_pos_atlas.x, mouse_pos_atlas.y), 0, game.SPECIES[current_species]["atlas"])
			if deleting:
				game.map[mouse_pos_atlas.x][mouse_pos_atlas.y] = game.EMPTY
				Map.erase_cell(Vector2i(mouse_pos_atlas.x, mouse_pos_atlas.y))

func resize(new_size=Field.size):
	# set scale
	var scale_factor = min(new_size.x/game.SIZE.x, new_size.y/game.SIZE.y)
	Map.scale = scale_factor * Vector2i(1,1)
	Background.size = scale_factor * game.SIZE + Vector2(32,32)

func set_game_size(new_size):
	Map.clear()
	game.set_size(new_size)
	resize()

func set_game(new_game):
	game = new_game
	load_map(new_game.random_map())
	self.resize()

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
				Map.set_cell(Vector2i(x,y), 0, game.SPECIES[game.map[x][y]]["atlas"])

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
