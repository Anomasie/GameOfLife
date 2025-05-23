extends Node
class_name Species

var my_name : String
var color = (Color.from_hsv(randf(), 1, 1) + Color.WHITE)/2
var chance = 0.16
var reproduction = {}
var survival = {}

# three examples:
const dict_plants = {
	"name": "plants",
	"color": Color.GREEN,
	"chance": 0.1,
	"reproduction": {
		"plancton": [0,1],
		"plants": [1,2]
	},
	"survival": {
		"plancton": [0,1],
		"plants": [0,1,2,3,4,5,6]
	}
}
const dict_plancton = {
	"name": "plancton",
	"color": Color.BLUE,
	"chance": 0.13,
	"reproduction": {
		"plants": [3,4,5,6,7,8],
		"plancton": [1,2,3],
		"predator": [0,1]
	},
	"survival": {
		"predator": [0,1,2,3],
		"plants": [1,2,3,4,5,6,7,8],
		"plancton": [1,2,3,4]
	}
}
const dict_predator = {
	"name": "predator",
	"color": Color.RED,
	"chance": 0.1,
	"reproduction": {
		"predator": [1,2],
		"plancton": [1,2,3,4,5,6,7,8]
	},
	"survival": {
		"plancton": [1,2,3,4,5,6,7,8],
		"predator": [0,1,2]
	}
}

static func generate_word(length=10, chars="abcdefghijklmnopqrstuvwxyz"):
	var word = ""
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

func _init():
	my_name = generate_word(10)
	# Conway's game of life rules
	reproduction[my_name] = [3]
	reproduction["sum"] = [3]
	survival[my_name] = [2,3]
	survival["sum"] = [2,3]

func to_dict() -> Dictionary:
	var dict = {}
	dict["name"] = self.my_name
	dict["color"] = self.color
	dict["chance"] = self.chance
	dict["reproduction"] = self.reproduction
	dict["survival"] = self.survival
	return dict

static func from_dict(dict) -> Species:
	var species = Species.new()
	if dict.has("name"):
		species.my_name = dict["name"]
	if dict.has("chance"):
		species.chance = dict["chance"]
	if dict.has("color"):
		species.color = dict["color"]
	if dict.has("reproduction"):
		species.reproduction = dict["reproduction"]
	if dict.has("survival"):
		species.survival = dict["survival"]
	return species
