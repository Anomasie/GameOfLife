extends Control

signal pressed

var was_pressed = false

func _on_button_pressed() -> void:
	was_pressed = true
	pressed.emit()
