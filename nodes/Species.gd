extends MarginContainer

signal species_changed
signal please_change_color

@onready var Name = $MarginContainer/Lines/GridContainer/NameEdit
@onready var Chance = $MarginContainer/Lines/GridContainer/ChanceEdit
@onready var RLedge = $MarginContainer/Lines/ReprContainer/Ledge
@onready var SLedge = $MarginContainer/Lines/SurvivalContainer/Ledge
@onready var ColorTexture = $MarginContainer/Lines/GridContainer/ColorTexture

func set_species(species) -> void:
	if typeof(species) != TYPE_DICTIONARY:
		species = species.to_dict()
	Name.placeholder_text = species["name"]
	Chance.value = species["chance"]
	ColorTexture.self_modulate = species["color"]
	SLedge.set_boxes(species["survival"]["sum"])
	RLedge.set_boxes(species["reproduction"]["sum"])

func get_species() -> Species:
	var dict = {}
	dict["name"] = Name.placeholder_text
	dict["chance"] = Chance.value
	dict["color"] = ColorTexture.self_modulate
	
	dict["reproduction"] = {}
	dict["reproduction"]["sum"] = RLedge.read_boxes()
	
	dict["survival"] = {}
	dict["survival"]["sum"] = SLedge.read_boxes()
	
	return Species.from_dict(dict)

func change_color(new_color) -> void:
	ColorTexture.self_modulate = new_color

func _on_ledge_boxes_changed() -> void:
	species_changed.emit(get_species())

func _on_name_edit_text_submitted(new_text: String) -> void:
	Name.placeholder_text = new_text
	Name.text = ""
	species_changed.emit(get_species())

func _on_color_button_pressed() -> void:
	please_change_color.emit()
