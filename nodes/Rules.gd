extends MarginContainer

signal changed_current_species

signal changed_size
signal game_changed
signal please_change_color

@export var SpeciesButtonScene : PackedScene

@onready var EditX = $Margin/Lines/Sep/LineEditX
@onready var EditY = $Margin/Lines/Sep/LineEditY

@onready var SpeciesEditor = $Margin/Lines/SpeciesEditor
@onready var SpeciesButtons = []
@onready var SpeciesButtonsParent = $Margin/Lines/SpeciesList/SpeciesButtons
@onready var AddButton = $Margin/Lines/SpeciesList/AddButton
@onready var DeleteButton = $Margin/Lines/SpeciesList/DeleteButton

const RANDOM_TRANSLATION = 0.185618
var current_color_index = 0

var current_species = 0
var disabled = 0

var game = GameOfLife.new()

func _ready():
	check_if_buttons_should_be_disabled()
	await get_tree().process_frame
	set_rules(game)
	game_changed.emit(game)

func _input(event):
	if event.is_action_pressed("scroll_down") or event.is_action_pressed("scroll_up"):
		if event.is_action_pressed("scroll_down"):
			current_species -= 1
		if event.is_action_pressed("scroll_up"):
			current_species += 1
		if current_species < 0:
			current_species = len(game.SPECIES) - 1
		elif current_species >= len(game.SPECIES):
			current_species = 0
		load_species()
		changed_current_species.emit(current_species)

func load_species(i=current_species) -> void:
	current_species = i
	changed_current_species.emit(current_species)
	var color_dict = {}
	for j in len(game.SPECIES):
		color_dict[game.SPECIES[j].my_name] = game.SPECIES[j].color
	if len(game.SPECIES) > 0:
		SpeciesEditor.set_species(game.SPECIES[i], color_dict)

func set_rules(new_game) -> void:
	disabled += 1
	game = new_game
	EditX.value = new_game.SIZE.x
	EditY.value = new_game.SIZE.y
	set_species(game.SPECIES)
	load_species()
	disabled -= 1

func set_species(new_species : Array) -> void:
	disabled += 1
	game.SPECIES = new_species
	if len(new_species) > len(SpeciesButtons):
		for i in len(new_species) - len(SpeciesButtons):
			add_species_ui(new_species[i+len(new_species)-1])
	if len(new_species) < len(SpeciesButtons):
		for i in len(SpeciesButtons) - len(new_species):
			delete_species_ui(i+len(new_species)-1)
	# set interior
	for i in len(SpeciesButtons):
		SpeciesButtons[i].modulate = new_species[i].color
	
	if current_species < len(new_species):
		load_species(current_species)
	else:
		load_species(0)
	disabled -= 1

func change_color(new_color : Color, index = current_species) -> void:
	game.SPECIES[index].color = new_color
	SpeciesEditor.set_species(game.SPECIES[index], game.get_color_dict())
	self.set_species(game.SPECIES)

func _on_species_editor_please_change_color() -> void:
	please_change_color.emit()

# signals

func _on_line_edit_x_value_changed(value: int) -> void:
	if disabled == 0:
		changed_size.emit(Vector2i(value, EditY.value))

func _on_line_edit_y_value_changed(value: int) -> void:
	if disabled == 0:
		changed_size.emit(Vector2i(EditX.value, value))

func _on_species_editor_species_changed(new_species) -> void:
	if disabled == 0:
		game.SIZE = Vector2i(EditX.value, EditY.value)
		game.SPECIES[current_species] = new_species
		game_changed.emit(game)

# multiple species

func check_if_buttons_should_be_disabled():
	DeleteButton.disabled = len(SpeciesButtons) == 0
	SpeciesEditor.visible = len(game.SPECIES) > 0

func add_species_ui(species = Species.new()) -> void:
	species.color = Color.from_hsv(current_color_index * RANDOM_TRANSLATION, 1, 1)
	current_color_index += 1
	# manage nodes
	SpeciesButtonsParent.add_child(SpeciesButtonScene.instantiate())
	SpeciesButtons.append(SpeciesButtonsParent.get_child(-1))
	SpeciesButtons[-1].pressed.connect(_on_species_button_pressed)
	SpeciesButtons[-1].modulate = species.color
	# emit signals
	check_if_buttons_should_be_disabled()

func delete_species_ui(index) -> void:
	SpeciesButtonsParent.get_child(index).queue_free()
	SpeciesButtons.remove_at(index)
	# handle buttons and signals
	check_if_buttons_should_be_disabled()

func _on_add_button_pressed() -> void:
	var new_species_data = Species.new()
	game.add_species(new_species_data)
	add_species_ui(new_species_data)
	if disabled == 0:
		game_changed.emit(game)
	# load new species
	load_species(len(game.SPECIES)-1)

func _on_delete_button_pressed() -> void:
	game.remove_species(current_species)
	delete_species_ui(current_species)
	if disabled == 0:
		game_changed.emit(game, current_species)
	# load next species
	if current_species > len(game.SPECIES):
		current_species = len(game.SPECIES) - 1
	load_species(0)

func _on_species_button_pressed() -> void:
	for i in len(SpeciesButtons):
		if SpeciesButtons and SpeciesButtons[i].was_pressed:
			load_species(i)
			SpeciesButtons[i].was_pressed = false
			return
