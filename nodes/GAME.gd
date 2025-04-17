extends Control

@onready var GameField = $Margin/GameField

# buttons
@onready var PlayButton = $Screen/Container/MarginContainer/GridContainer/PlayButton

func _on_play_button_pressed() -> void:
	GameField.set_pause(PlayButton.on)

func _on_delete_button_pressed() -> void:
	GameField.delete_all()

func _on_random_button_pressed() -> void:
	GameField.load_map(GameOfLife.random_map())
