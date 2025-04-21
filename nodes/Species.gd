extends MarginContainer

signal species_changed
signal please_change_color

@export var LedgeScene : PackedScene

@onready var Name = $MarginContainer/Lines/GridContainer/NameEdit
@onready var Chance = $MarginContainer/Lines/GridContainer/ChanceEdit
@onready var RLedges = $MarginContainer/Lines/ReprContainer
@onready var SLedges = $MarginContainer/Lines/SurvivalContainer
@onready var ColorTexture = $MarginContainer/Lines/GridContainer/ColorTexture

func set_species(species, color_dict) -> void:
	if typeof(species) != TYPE_DICTIONARY:
		species = species.to_dict()
	Name.placeholder_text = species["name"]
	Chance.value = species["chance"]
	ColorTexture.self_modulate = species["color"]
	
	set_ledges(species, "survival", SLedges, color_dict)
	set_ledges(species, "reproduction", RLedges, color_dict)

func set_ledges(species, type, Ledges, color_dict):
	var len_requirements = len(species[type].keys())
	if len_requirements < len(Ledges.get_children())+1: # add box
		for i in len(Ledges.get_children())+1 - len_requirements:
			Ledges.get_child(i + len_requirements - 1).hide()
	elif len_requirements > len(Ledges.get_children())+1: # hide box
		for i in len_requirements - len(Ledges.get_children())-1:
			Ledges.add_child(LedgeScene.instantiate())
	
	Ledges.get_child(0).show()
	for i in len_requirements:
		var key = species[type].keys()[i]
		var color
		if key != "sum" and color_dict.has(key):
			color = color_dict[key]
		Ledges.get_child(i+1).set_boxes(species[type][key], key, color)
		Ledges.get_child(i+1).show()

func get_species() -> Species:
	var dict = {}
	dict["name"] = Name.placeholder_text
	dict["chance"] = Chance.value
	dict["color"] = ColorTexture.self_modulate
	
	dict["reproduction"] = read_ledges(RLedges.get_children())
	dict["survival"] = read_ledges(SLedges.get_children())
#	dict["survival"]["sum"] = SLedge.read_boxes()
	
	return Species.from_dict(dict)

func read_ledges(Ledges) -> Dictionary:
	Ledges.remove_at(0)
	var dict = {}
	for Ledge in Ledges:
		dict[Ledge.my_name] = Ledge.read_boxes()
	return dict

func _on_ledge_boxes_changed() -> void:
	species_changed.emit(get_species())

func _on_name_edit_text_submitted(new_text: String) -> void:
	Name.placeholder_text = new_text
	Name.text = ""
	species_changed.emit(get_species())

func _on_color_button_pressed() -> void:
	please_change_color.emit()

func _on_chance_edit_value_changed(_value: float) -> void:
	species_changed.emit(get_species())
