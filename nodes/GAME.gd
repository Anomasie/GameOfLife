extends Control

@onready var GameOfLife = $Margin/GameOfLife

# buttons
@onready var PlayButton = $Screen/Container/MarginContainer/GridContainer/PlayButton

func _on_play_button_pressed() -> void:
	GameOfLife.set_pause(PlayButton.on)


func _on_delete_button_pressed() -> void:
	GameOfLife.delete_all()
