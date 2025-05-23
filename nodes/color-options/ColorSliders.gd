@tool
extends MarginContainer

signal color_changed

@onready var Preview = $Dialogue/Content/Lines/Columns/Frame/MarginContainer/Preview

@onready var HueTexture = $Dialogue/Content/Lines/Columns/Sliders/Hue/Texture
@onready var HueSlider = $Dialogue/Content/Lines/Columns/Sliders/Hue/Slider
@onready var SatTexture = $Dialogue/Content/Lines/Columns/Sliders/Saturation/Texture
@onready var SatSlider = $Dialogue/Content/Lines/Columns/Sliders/Saturation/Slider
@onready var ValueTexture = $Dialogue/Content/Lines/Columns/Sliders/Value/Texture
@onready var ValueSlider = $Dialogue/Content/Lines/Columns/Sliders/Value/Slider

@onready var Presets = $Dialogue/Content/Lines/Columns/Sliders/Presets.get_children()
@onready var UserPresetNode = $Dialogue/Content/Lines/LastLine/UserPresets
@onready var UserPresetsLabel = $Dialogue/Content/Lines/LastLine/UserPresets/UserPresetsLabel
@onready var UserPresets = $Dialogue/Content/Lines/LastLine/UserPresets.get_children()

@onready var Hash = $Dialogue/Content/Lines/Columns/Sliders/Presets/Hash

@onready var AddButton = $Dialogue/Content/Lines/LastLine/AddButton
@onready var RandomColorButton = $Dialogue/Content/Lines/Columns/Buttons/RandomButton
@onready var CloseButton = $CloseButton

var saved_colors = [
	Color("#faf3d4"),
	Color("#e6c853"),
	Color("#e0003f"),
	Color("#007bde"),
	Color("#282445"),
	Color("#2a7336"),
	Color("#3ccf53")
	]
var uniform_coloring = false

var disabled = 0

var user_saved_colors = []

func _ready():
	# connect preset-colors
	for i in len(Presets):
		if Presets[i] is TextureButton:
			Presets[i].pressed.connect(_on_preset_pressed.bind(i))
	UserPresets.pop_front()
	for i in len(UserPresets):
		if UserPresets[i] is TextureButton:
			UserPresets[i].pressed.connect(_on_user_preset_pressed.bind(i))
	# open something
	open(Color.WHITE)

# open and close

func open(color):
	# load ui
	set_color(color)
	load_preset_colors()
	if not Engine.is_editor_hint():
		load_user_preset_colors()
		show()

func close():
	hide()

# content

func load_preset_colors():
	for i in len(Presets):
		if Presets[i] is TextureButton:
			Presets[i].modulate = saved_colors[ min(len(saved_colors) - 1,  i) ]

func load_user_preset_colors():
	for i in len(UserPresets):
		if i < len(user_saved_colors):
			UserPresets[i].modulate = user_saved_colors[i]
		else:
			UserPresets[i].modulate = Color.WHITE
#	UserPresetNode.visible = (len(Global.user_saved_colors) > 0)

func set_color(color = get_color()):
	disabled += 1
	
	# preview picture
	Preview.modulate = color
	# update backgrounds
	## value slider
	ValueTexture.texture.gradient.colors[0] = Color.from_hsv(
		float(HueSlider.value) / HueSlider.max_value,
		color.s,
		0)
	ValueTexture.texture.gradient.colors[1] = Color.from_hsv(
		float(HueSlider.value) / HueSlider.max_value,
		color.s,
		1)
	## saturation slider
	SatTexture.texture.gradient.colors[0] = Color.from_hsv(
		float(HueSlider.value) / HueSlider.max_value,
		0,
		color.v)
	SatTexture.texture.gradient.colors[1] = Color.from_hsv(
		float(HueSlider.value) / HueSlider.max_value,
		1,
		color.v)
	# update slider values
	if color.v > 0 and color.s > 0:
		HueSlider.value = color.h * HueSlider.max_value
	if color.v > 0:
		SatSlider.value = color.s * SatSlider.max_value
	ValueSlider.value = color.v * ValueSlider.max_value
	# update hash
	delete_hash_text()
	
	disabled -= 1

func get_color():
	return Color.from_hsv(
		float(HueSlider.value) / HueSlider.max_value,
		float(SatSlider.value) / SatSlider.max_value,
		float(ValueSlider.value) / ValueSlider.max_value
	)

func _on_slider_value_changed(_value):
	set_color()
	if disabled == 0:
		color_changed.emit()

func _on_preset_pressed(i):
	set_color(Presets[i].modulate)
	if disabled == 0:
		color_changed.emit()

func _on_user_preset_pressed(i):
	if UserPresets[i].visible:
		set_color(UserPresets[i].modulate)
		if disabled == 0:
			color_changed.emit()

func _on_add_button_pressed():
	user_saved_colors.push_front(get_color())
	while len(user_saved_colors) > len(UserPresets):
		user_saved_colors.pop_back()
	load_user_preset_colors()

# html text

func delete_hash_text():
	Hash.text = ""
	Hash.placeholder_text = Preview.modulate.to_html(false)

func _on_hash_text_submitted(new_text):
	Hash.release_focus()
	if len(new_text) == 6:
		set_color(Color.from_string(new_text, Preview.modulate))
		color_changed.emit()
	else:
		delete_hash_text()

func _on_hash_focus_exited():
	_on_hash_text_submitted(Hash.text)

# end dialogue

func _on_close_button_pressed():
	self.hide()

# random color

func _on_random_button_pressed() -> void:
	open(Color.from_hsv(randf(), randf(), randf()))
	color_changed.emit()
