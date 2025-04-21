@tool
extends MarginContainer

const BORDER_CELL = Vector2i(1,0)

var game = GameOfLife.new()
var map = game.random_map()

# states
var current_species = 0

var marking = false
var deleting = false

@export var MapScene : PackedScene

@onready var Maps = []
@onready var Field = $Margin/Field
@onready var WorldTime = $WorldTime

@onready var Margin = $Margin
@onready var Background = $Background

func _ready():
	# load map
	load_new_maps()
	await get_tree().process_frame
	self.resize()

func _process(_delta: float) -> void:
	if marking or deleting:
		var mouse_pos_relative_unscaled = get_viewport().get_mouse_position() - Field.get_global_position()
		var mouse_pos_atlas = Vector2i(
			mouse_pos_relative_unscaled.x / Field.scale.x,
			mouse_pos_relative_unscaled.y / Field.scale.y
		)
		if mouse_pos_atlas.x >= 0 and mouse_pos_atlas.x < game.SIZE.x and mouse_pos_atlas.y >= 0 and mouse_pos_atlas.y < game.SIZE.y:
			if marking:
				map[mouse_pos_atlas.x][mouse_pos_atlas.y] = current_species
				Maps[current_species].set_cell(Vector2i(mouse_pos_atlas.x, mouse_pos_atlas.y), 0, Vector2i(0,0))
			if deleting:
				map[mouse_pos_atlas.x][mouse_pos_atlas.y] = game.EMPTY
				Maps[current_species].erase_cell(Vector2i(mouse_pos_atlas.x, mouse_pos_atlas.y))

func resize(new_size=Field.size):
	# set scale
	var scale_factor = min(new_size.x/game.SIZE.x, new_size.y/game.SIZE.y)
	Field.scale = scale_factor * Vector2i(1,1)
	Background.size = scale_factor * game.SIZE + Vector2(32,32)
	print(new_size.x/game.SIZE.x, " ", new_size.y/game.SIZE.y, " -> ", scale_factor)

func set_current_species(index):
	current_species = index

func set_game_size(new_size):
	for Map in Maps:
		Map.clear()
	game.set_size(new_size)
	resize()

func set_game(new_game):
	if not game or new_game.SIZE != game.SIZE:
		game = new_game
		map = game.random_map()
		load_new_maps()
		self.resize()
	else:
		game = new_game
		load_new_maps()

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

func load_new_maps() -> void:
	# delete everything
	if len(game.SPECIES) > len(Maps):
		for i in len(game.SPECIES) - len(Maps):
			Field.add_child(MapScene.instantiate())
			Maps.append(Field.get_child(-1))
	if len(game.SPECIES) < len(Maps):
		for i in len(Maps) - len(game.SPECIES):
			Maps[-1].queue_free()
			Maps.pop_back()
	# set interior
	for i in len(Maps):
		Maps[i].self_modulate = game.SPECIES[i].color
	set_map()

func load_random_map() -> void:
	# delete everything
	for Map in Maps:
		Map.clear()
	
	# set interior
	map = game.random_map()
	set_map()

func delete_species(index) -> void:
	for x in range(game.SIZE.x):
		for y in range(game.SIZE.y):
			if map[x][y] == index:
				map[x][y] = game.EMPTY
			elif map[x][y] > index:
				map[x][y] -= 1

func read_map() -> void:
	for x in range(game.SIZE.x):
		var array = []
		array.resize(game.SIZE.y)
		for y in range(game.SIZE.y):
			var data = -1
			for Map in Maps:
				data = max(data, Map.get_cell_atlas_coords(Vector2i(x,y)))
			array[y] = int(typeof(data) != TYPE_NIL and data == game.NORMAL_CELL) * 2
		game.map[x] = array

func set_map(new_map = map) -> void:
	map = new_map
	for x in range(game.SIZE.x):
		for y in range(game.SIZE.y):
			if map[x][y] == game.EMPTY:
				for Map in Maps:
					Map.erase_cell(Vector2i(x,y))
			else:
				Maps[map[x][y]].set_cell(Vector2i(x,y), 0, Vector2i(0,0))

func next_step() -> void:
	set_map(game.get_next_step(map))

func _on_world_time_timeout() -> void:
	if map:
		next_step()

func print_matrix(mat=map) -> void:
	for x in len(mat):
		print(mat[x])

## colors

func change_current_color(new_color):
	Maps[current_species].self_modulate = new_color

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
