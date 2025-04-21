extends MarginContainer

signal boxes_changed

@onready var Sum = $Margin/Sep/Control/Sum
@onready var Quad = $Margin/Sep/Control/Quad

@onready var Boxes = $Margin/Sep/Container/Ledge.get_children()
@onready var Labels = $Margin/Sep/Container/Skin.get_children()

var my_name : String

func _ready():
	for i in len(Boxes):
		Boxes[i].pressed.connect(_on_box_pressed)

func read_boxes() -> Array:
	var array = []
	for i in len(Boxes):
		if Boxes[i].button_pressed: array.append(i)
	return array

func set_boxes(array, new_name, color) -> void:
	my_name = new_name
	for i in len(Boxes):
		Boxes[i].button_pressed = i in array
	Sum.visible = typeof(color) == TYPE_NIL
	Quad.visible = not Sum.visible
	if typeof(color) != TYPE_NIL:
		Quad.modulate = color
	coordinate_boxes()

func _on_box_pressed():
	boxes_changed.emit()
	coordinate_boxes()

func coordinate_boxes():
	for i in len(Boxes):
		if Boxes[i].button_pressed:
			Labels[i].text = ""
		else:
			Labels[i].text = str(i)
