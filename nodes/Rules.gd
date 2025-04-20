extends MarginContainer

signal changed_size
signal game_changed

@onready var EditX = $Margin/Lines/Sep/LineEditX
@onready var EditY = $Margin/Lines/Sep/LineEditY

@onready var Species = $Margin/Lines/Species

var disabled = 0

func set_rules(new_game) -> void:
	disabled += 1
	EditX.value = new_game.SIZE.x
	EditY.value = new_game.SIZE.y
	Species.set_species(new_game.SPECIES[0])
	disabled -= 1

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
