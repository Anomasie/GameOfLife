extends MarginContainer

signal species_changed

@onready var Name = $MarginContainer/Lines/GridContainer/NameEdit
@onready var Chance = $MarginContainer/Lines/GridContainer/ChanceEdit
@onready var RLedge = $MarginContainer/Lines/ReprContainer/Ledge
@onready var SLedge = $MarginContainer/Lines/SurvivalContainer/Ledge

func set_species(species) -> void:
	Name.placeholder_text = species["name"]
	Chance.value = species["chance"]
	SLedge.set_boxes(species["survival"]["sum"])
	RLedge.set_boxes(species["reproduction"]["sum"])

func get_species() -> Dictionary:
	var dict = {}
	dict["name"] = Name.placeholder_text
	dict["chance"] = Chance.value
	dict["atlas"] = Vector2i(0,0)
	
	dict["reproduction"] = {}
	dict["reproduction"]["sum"] = RLedge.read_boxes()
	
	dict["survival"] = {}
	dict["survival"]["sum"] = SLedge.read_boxes()
	
	return dict

func _on_ledge_boxes_changed() -> void:
	species_changed.emit(get_species())

func _on_name_edit_text_submitted(new_text: String) -> void:
	Name.placeholder_text = Name.text
	Name.text = ""
	species_changed.emit(get_species())
