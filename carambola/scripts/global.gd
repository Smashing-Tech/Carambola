extends Node

const app_version = ["2021", "04", "10", "Alpha"]
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
	
	for i in range(0, 68):
		textures.decals.append(load("res://assets/decals/" + str(i - 4) + ".png"))
		textures.decals[i].set_flags(Texture.FLAGS_DEFAULT)
	
	# Load default templates
	self.load_templates("res://assets/default/templates.xml")
	
	# Load options
	self.load_options()

#
# Options and related things
#
var options = {
	save_backup_scene = true,
	enable_carambola_extensions = true,
	show_xml_in_status = false,
	enable_stonehack = false,
}

func save_options():
	var cf = ConfigFile.new()
	
	for d in options.keys():
		cf.set_value("General", d, options[d])
	
	cf.save("user://options.ini")
	
	print("Saved options to options.ini.")

func load_options():
	var cf = ConfigFile.new()
	
	if (cf.load("user://options.ini") != OK):
		print("Error loading config file; this is normal on first run.")
		return
	
	for d in options.keys():
		options[d] = cf.get_value("General", d, options[d])

# Needed, even if not enabled...
var templates = {
	"?Carambola": {"color": "0.0 1.0 0.0"}, # This one can be used to make sure that templates system is working
}

# Load a templates file into a double-dictionary that contains the templates
func load_templates(path : String):
	var xml = XMLParser.new()
	xml.open(path)
	
	while (!xml.read()):
		var ent_name = ""
		# This is needed so godot doesn't complain if we were to get_node_name on NODE_TEXT type
		if (xml.get_node_type() == XMLParser.NODE_ELEMENT):
			ent_name = xml.get_node_name()
		else:
			ent_name = ""
		
		if (ent_name == "template" && xml.get_node_type() == XMLParser.NODE_ELEMENT):
			var temp_name = xml.get_named_attribute_value_safe("name")
			if (!name):
				print("Warning: Template without a name has been skipped.")
				continue
			
			# Move forward until the get to the template's properties element
			while (xml.get_node_type() != XMLParser.NODE_ELEMENT || xml.get_node_name() != "properties"):
				xml.read()
			
			# Just making sure
			assert(xml.get_node_name() == "properties")
			
			var temp_dict = {}
			for i in range(0, xml.get_attribute_count()):
				temp_dict[xml.get_attribute_name(i)] = xml.get_attribute_value(i)
			
			templates[temp_name] = temp_dict
	
	print("Info: Loaded templates file.")

# Get a loaded tile texture
func get_tile(id : int):
	return textures.tiles[id % 64]

# Get a loaded decal texture
func get_decal(id : int):
	return textures.decals[(id + 4) % 68]

# Selection-related
var selection
var selectionChanged : bool = false

# Set an active object
func set_active(object : Node):
	self.selection = object
	self.selectionChanged = true

# Segment-related
var seg_size : Vector3 = Vector3()
var seg_template : String = ""
