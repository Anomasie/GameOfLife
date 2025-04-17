extends Control

@onready var GameField = $Margin/GameField

@onready var PlayButton = $Screen/Container/MarginContainer/GridContainer/PlayButton

const TIME_SLIDER_HALF_VALUE = 1
@onready var TimeSlider = $Screen/Container/MarginContainer/GridContainer/TimeSlider

const STANDARD_TIME = 0.1
var last_time = STANDARD_TIME

func _ready() -> void:
	TimeSlider.value = slider_descaled(STANDARD_TIME)

# buttons

func _on_play_button_pressed() -> void:
	GameField.set_pause(not PlayButton.on)

func _on_delete_button_pressed() -> void:
	GameField.delete_all()

func _on_random_button_pressed() -> void:
	GameField.load_map() # load random is standard

# slider

func slider_scaled(x = float( TimeSlider.value )) -> float:
	if x >= TimeSlider.max_value:
		return -1
	else:
		return - log(float(TimeSlider.max_value - x)/TimeSlider.max_value) * TIME_SLIDER_HALF_VALUE

func slider_descaled(y) -> float:
	if y < 0:
		return TimeSlider.max_value
	else:
		return int( TimeSlider.max_value * (1 - exp( - float(y) / TIME_SLIDER_HALF_VALUE )) ) + 1

func _on_time_slider_value_changed(value: float) -> void:
	var scaled_value = slider_scaled(value)
	
	if scaled_value == -1:
		GameField.set_pause(true)
		PlayButton.set_disabled(true)
	else:
		scaled_value = max(scaled_value, 0.001)
		GameField.set_time(scaled_value)
		if last_time == -1: GameField.set_pause(false)
		PlayButton.set_disabled(false)
	
	last_time = scaled_value
