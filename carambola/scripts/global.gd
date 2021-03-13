extends Node

const app_version = ["2021", "03", "13", "Alpha"]
var textures = {
	tiles = [],
	decals = [],
	powerups = {"ballfrenzy": null, "slomotion": null, "nitroballs": null},
}

func _ready():
	# Load textures
	for i in range(0, 64):
		textures.tiles.append(load("res://assets/tiles/" + str(i) + ".png"))
		textures.tiles[i].set_flags(Texture.FLAGS_DEFAULT)

func get_tile(id : int):
	return textures.tiles[id % 64]

var selection
var selectionChanged : bool = false

var seg_size : Vector3 = Vector3()
var seg_template : String = ""

func set_active(object : Node):
	self.selection = object
	self.selectionChanged = true
