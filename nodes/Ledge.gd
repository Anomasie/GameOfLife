extends MarginContainer

signal boxes_changed

@onready var Boxes = $Margin/Ledge.get_children()
@onready var Labels = $Margin/Skin.get_children()

func _ready():
	for i in len(Boxes):
		Boxes[i].pressed.connect(_on_box_pressed)

func read_boxes() -> Array:
	var array = []
	for i in len(Boxes):
		if Boxes[i].button_pressed: array.append(i)
	return array

func set_boxes(array) -> void:
	for i in len(Boxes):
		Boxes[i].button_pressed = i in array
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
