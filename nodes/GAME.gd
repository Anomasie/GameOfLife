extends Control

# game field
@onready var GameField = $Screen/Lines/Sep/GameField

# buttons
@onready var PlayButton = $Screen/Lines/Time/Content/GridContainer/PlayButton

# time
const TIME_SLIDER_HALF_VALUE = 1
@onready var TimeSlider = $Screen/Lines/Time/Content/GridContainer/TimeSlider
const STANDARD_TIME = 0.1
var last_time = STANDARD_TIME

# rules
@onready var Rules = $Screen/Lines/Sep/Rules
@onready var ColorSliders = $Screen/ColorSliders

# ready

func _ready() -> void:
	Rules.set_rules(GameField.game)
	TimeSlider.value = slider_descaled(STANDARD_TIME)
	# connect
	get_tree().get_root().size_changed.connect(resize)
	# hide & show
	ColorSliders.hide()

func resize():
	$ResizeTimer.start()
	await $ResizeTimer.timeout
	GameField.resize()

# buttons

func _on_play_button_pressed() -> void:
	GameField.set_pause(not PlayButton.on)

func _on_delete_button_pressed() -> void:
	GameField.delete_all()

func _on_random_button_pressed() -> void:
	GameField.load_random_map() # load random is standard

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

# rules

func _on_rules_changed_size(new_size) -> void:
	GameField.set_game_size(new_size)

func _on_rules_game_changed(new_game, deleted_species=-1) -> void:
	if deleted_species >= 0:
		GameField.delete_species(deleted_species)
	GameField.set_game(new_game)

func _on_rules_please_change_color() -> void:
	ColorSliders.open(GameField.game.SPECIES[GameField.current_species]["color"])

# color sliders

func _on_color_sliders_color_changed() -> void:
	var color = ColorSliders.get_color()
	GameField.change_current_color(color)
	Rules.change_color(color)


func _on_rules_changed_current_species(index) -> void:
	GameField.set_current_species(index)


func _on_debug_button_pressed() -> void:
	print(GameField.Maps)
