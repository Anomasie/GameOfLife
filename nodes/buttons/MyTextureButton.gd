@tool
extends TextureButton

@export var tex : AtlasTexture

func _ready():
	set_textures()
	set_texture_angles()

func set_textures():
	self.texture_normal = tex.duplicate()

func set_texture_angles():
	var anchor = self.texture_normal.region.position.y
	self.texture_hover = self.texture_normal.duplicate()
	self.texture_pressed = self.texture_normal.duplicate()
	self.texture_disabled = self.texture_normal.duplicate()
	self.texture_normal.region = Rect2(0, anchor, 32, 32)
	self.texture_hover.region = Rect2(32, anchor, 32, 32)
	self.texture_pressed.region = Rect2(64, anchor, 32, 32)
	self.texture_disabled.region  = Rect2(96, anchor, 32, 32)
