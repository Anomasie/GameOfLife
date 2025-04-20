extends MarginContainer

signal changed_size
signal game_changed
signal please_change_color

signal species_added
signal species_deleted

@export var SpeciesButtonScene : PackedScene

@onready var EditX = $Margin/Lines/Sep/LineEditX
@onready var EditY = $Margin/Lines/Sep/LineEditY

@onready var SpeciesEditor = $Margin/Lines/SpeciesEditor
@onready var SpeciesButtons = []
@onready var SpeciesButtonsParent = $Margin/Lines/SpeciesList/SpeciesButtons
@onready var AddButton = $Margin/Lines/SpeciesList/AddButton
@onready var DeleteButton = $Margin/Lines/SpeciesList/DeleteButton

var current_species = 0
var disabled = 0

func _ready():
	check_if_buttons_should_be_disabled()
	await get_tree().process_frame
	set_species(self.get_owner().GameField.game.SPECIES)

func load_species(i=0) -> void:
	if typeof(i) == TYPE_INT:
		SpeciesEditor.set_species(self.get_owner().GameField.game.SPECIES[i])
	else:
		SpeciesEditor.set_species(i)

func set_rules(new_game) -> void:
	disabled += 1
	EditX.value = new_game.SIZE.x
	EditY.value = new_game.SIZE.y
	SpeciesEditor.set_species(new_game.SPECIES[0])
	disabled -= 1

func set_species(new_species : Array = self.get_owner().GameField.game.SPECIES) -> void:
	if len(new_species) > len(SpeciesButtons):
		for i in len(new_species) - len(SpeciesButtons):
			SpeciesButtonsParent.add_child(SpeciesButtonScene.instantiate())
			SpeciesButtons.append(SpeciesButtonsParent.get_child(-1))
	if len(new_species) < len(SpeciesButtons):
		for i in len(SpeciesButtons) - len(new_species):
			SpeciesButtons[-1].queue_free()
			SpeciesButtons.pop_back()
	# set interior
	for i in len(SpeciesButtons):
		SpeciesButtons[i].modulate = new_species[i].color
	
	if current_species < len(new_species):
		load_species(current_species)
	else:
		load_species(0)

func change_color(new_color : Color) -> void:
	SpeciesEditor.change_color(new_color)
	self.set_species()

# signals

func _on_line_edit_x_value_changed(value: int) -> void:
	if disabled == 0:
		changed_size.emit(Vector2i(value, EditY.value))

func _on_line_edit_y_value_changed(value: int) -> void:
	if disabled == 0:
		changed_size.emit(Vector2i(EditX.value, value))

func _on_species_species_changed(new_species) -> void:
	if disabled == 0:
		var new_game = GameOfLife.new(
			Vector2i(EditX.value, EditY.value),
			[new_species]
		)
		game_changed.emit(new_game)

func _on_species_please_change_color() -> void:
	please_change_color.emit()

# multiple species

func check_if_buttons_should_be_disabled():
	DeleteButton.disabled = len(SpeciesButtons) == 0

func _on_add_button_pressed() -> void:
	SpeciesButtonsParent.add_child(SpeciesButtonScene.instantiate())
	SpeciesButtons.append(SpeciesButtonsParent.get_child(-1))
	SpeciesButtons[-1].pressed.connect(_on_species_button_pressed)
	
	var new_species_data = Species.new()
	
	SpeciesButtons[-1].modulate = new_species_data.color
	
	species_added.emit(new_species_data)
	load_species(new_species_data)
	
	check_if_buttons_should_be_disabled()

func _on_delete_button_pressed() -> void:
	SpeciesButtonsParent.get_child(current_species).queue_free()
	SpeciesButtons.remove_at(current_species)
	
	species_deleted.emit(current_species)
	load_species(current_species)
	
	check_if_buttons_should_be_disabled()

func _on_species_button_pressed():
	for i in len(SpeciesButtons):
		if SpeciesButtons[i].was_pressed:
			load_species(i)
			SpeciesButtons[i].was_pressed = false
			return
