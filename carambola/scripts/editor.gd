extends Spatial

var last_event
var cam
var gui
var objects = []

var DEBUG_has_freed_lights : bool = false

func _ready():
	cam = $Camera
	gui = $UI
	
	gui.get_node("Menubar").get_node("Objects").get_popup().connect("id_pressed", self, "handle_objects_menu")
	gui.get_node("Menubar").get_node("File").get_popup().connect("id_pressed", self, "handle_file_menu")
	gui.get_node("Menubar").get_node("Tools").get_popup().connect("id_pressed", self, "handle_tools_menu")
	gui.get_node("Menubar").get_node("Help").get_popup().connect("id_pressed", self, "handle_help_menu")
	gui.get_node("SegFile").connect("file_selected", self, "serialise_segment")
	gui.get_node("SegLoad").connect("file_selected", self, "load_segment")
	gui.get_node("TemplateLoad").connect("file_selected", self, "load_templates")

func _input(event):
	last_event = event

func _physics_process(delta):
	# Generate XML is status bar
	if (globals.options["show_xml_in_status"] and globals.selection):
		gui.log_event(globals.selection.asXMLElement())
	
	# Update the UI
	gui.update()
	
	# Reset selectionChanged
	globals.selectionChanged = false
	
	# Remove any invalid objects from the list
	# NOTE: Too agressive, also caused slow preformance in some cases
#	var new_list = []
#	for o in objects:
#		if (!is_instance_valid(o)):
#			new_list.append(o)
#	objects = new_list
	
	# Update keyboard bindings
	self.camera_update(delta)

func camera_update(delta):
	cam.translation.z -= (Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")) * 5.0 * delta
	if (Input.is_key_pressed(KEY_TAB)):
		cam.rotation_degrees.z += (Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")) * 50.0 * delta
	
	# Handle other keys here too
	if (Input.is_key_pressed(KEY_DELETE)):
		self.free_object()
	
	if (Input.is_key_pressed(KEY_CONTROL)):
		if (Input.is_key_pressed(KEY_SHIFT)):
			if (Input.is_key_pressed(KEY_B)):
				self.new_box()
			
			if (Input.is_key_pressed(KEY_O)):
				self.new_obstacle()
		
		# Debug feature to free lights since they can be SLOW!
		if (Input.is_key_pressed(KEY_ALT)):
			if (Input.is_key_pressed(KEY_F) and Input.is_key_pressed(KEY_C)):
				if (!DEBUG_has_freed_lights):
					$DirectionalLight.free()
					$DirectionalLight2.free()
					$DirectionalLight3.free()
					$DirectionalLight4.free()
					DEBUG_has_freed_lights = true
					print("Debug: Freed lights!")
					gui.log_event("Debug: Freed lights!")
		
		if (Input.is_key_pressed(KEY_S)):
			gui.show_file_select()
		
		if (Input.is_key_pressed(KEY_O)):
			gui.show_load_select()
		
		if (Input.is_key_pressed(KEY_R)):
			cam.translation = Vector3(0, 1, 4)
			cam.rotation_degrees = Vector3(0, 0, 0)


func handle_file_menu(id):
	if (id == 7):
		self.close_segment()
	
	if (id == 0):
		gui.show_load_select()
	
	if (id == 1):
		gui.show_file_select()
	
	if (id == 3):
		gui.show_bake()
	
	if (id == 5):
		gui.set_output_and_show(self.segment_to_xml())

func handle_objects_menu(id):
	# Place a box
	if (id == 0):
		self.new_box()
	
	# Place an obstacle
	if (id == 1):
		self.new_obstacle()
	
	if (id == 6):
		self.new_decal()
	
	# Free an object
	if (id == 3):
		self.free_object()
	
	if (id == 11):
		gui.show_options()

func handle_tools_menu(id):
	if (id == 0):
		gui.show_template_select()

func handle_help_menu(id):
	if (id == 1):
		gui.show_about()

## ############# ##
## Serialisation ##
## ############# ##

# Converts the segment to an XML string with no ending new line
func segment_to_xml():
	var seg : String = ""
	
	# Compose the starting and ending tags
	var xml_start = "<segment "
	xml_start += "size=\"" + str(globals.seg_size.x) + " " + str(globals.seg_size.y) + " " + str(globals.seg_size.z) + "\" "
	if (globals.seg_template):
		xml_start += "template=\"" + globals.seg_template + "\" "
	xml_start += ">\n"
	var xml_end = "</segment>"
	
	# Store the Carambola credit line
	seg += "<!-- Exported with Carambola version " + globals.app_version[0] + "." + globals.app_version[1] + "." + globals.app_version[2] + " -->\n"
	
	# Store the starting tag
	seg += xml_start
	
	# Store a line to the file for each obstacle
	for obj in objects:
		if (is_instance_valid(obj)):
			seg += "\t" + obj.asXMLElement() + "\n"
	
	# Store the ending line
	seg += xml_end
	
	return seg

# Saves the segment as an XML file
func serialise_segment(path : String):
	var file = File.new()
	
	# GZIP file export does not seem to work in this version of Godot
	# file.open_compressed(path, File.WRITE, File.COMPRESSION_GZIP)
	var error = file.open(path, File.WRITE)
	if (error):
		gui.log_event("Could not load file at " + path + ".")
		return
	
	file.store_line(self.segment_to_xml())
	
	file.close()

# Makes a backup copy of a segment with a semi-unique name
func backup_segment():
	var datetime = OS.get_datetime(true)
	self.serialise_segment("user://backup_" + str(datetime.year) + str(datetime.month) + str(datetime.day) + str(datetime.hour) + str(datetime.minute) + str(datetime.second) + ".xml")

# Loads a segment into the editor
func load_segment(path : String):
	# Serialise the current segment then wipe it
	if (globals.options["save_backup_scene"]):
		globals.selection = null
		self.backup_segment()
	self.close_segment()
	
	# Start loading the new segment
	var file = XMLParser.new()
	
	# For the number of incompatible objects
	var not_loaded_count : int = 0
	
	file.open(path)
	
	var loaded_segment_data : bool = false
	while (!file.read()):
		var objectType = file.get_node_name()
		
		# Load the main segment (will only happen once)
		if (objectType == "segment"):
			if (loaded_segment_data): continue
			
			# This is a sour hack (even if it looks simple)
			gui.segmentPanel.get_node("Size").text = file.get_named_attribute_value_safe("size")
			gui.segmentPanel.get_node("Template").text = file.get_named_attribute_value_safe("template")
			
			loaded_segment_data = true
		
		# Load a box
		if (objectType == "box"):
			var ent = EBox.new()
			
			var size = file.get_named_attribute_value_safe("size").split_floats(" ")
			if (len(size) == 3):
				ent.size = Vector3(size[0], size[1], size[2])
			else:
				ent.size = Vector3(0.5, 0.5, 0.5)
			
			var pos = file.get_named_attribute_value_safe("pos").split_floats(" ")
			if (len(pos) == 3):
				ent.position = Vector3(pos[0], pos[1], pos[2])
			else:
				ent.position = Vector3(0.5, 0.5, 0.5)
			
			ent.template = file.get_named_attribute_value_safe("template")
			
			if (file.get_named_attribute_value_safe("visible") == "1"):
				ent.visible = true
			else:
				ent.visible = false
			
			var tile = file.get_named_attribute_value_safe("tile")
			if (tile):
				ent.tile = int(tile)
			
			var colour = file.get_named_attribute_value_safe("color").split_floats(" ")
			if (len(colour) == 3):
				ent.colour = Color(colour[0], colour[1], colour[2], 1.0)
			elif (len(colour) == 4):
				ent.colour = Color(colour[0], colour[1], colour[2], colour[3])
			else:
				ent.colour = Color(0.5, 0.5, 0.5, 1.0)
			
			
			if (file.get_named_attribute_value_safe("reflection") == "1"):
				ent.reflection = true
			else:
				ent.reflection = false
			
			# For Carambola extensions
			if (globals.options.enable_carambola_extensions):
				var n = file.get_named_attribute_value_safe("_Name")
				if (n): ent.editor_name = n
				
				n = (file.get_named_attribute_value_safe("_Stone") == "0")
				if (n): ent.stone = false
			
			self.add_child(ent)
			objects.append(ent)
		
		# Load an obstacle
		elif (objectType == "obstacle"):
			# skip stonehack obstacles
			if (file.get_named_attribute_value_safe("IMPORT_IGNORE") == "STONEHACK_IGNORE"):
				continue
			
			var ent = EObstacle.new()
			
			var pos = file.get_named_attribute_value_safe("pos").split_floats(" ")
			if (len(pos) == 3):
				ent.position = Vector3(pos[0], pos[1], pos[2])
			else:
				ent.position = Vector3(0.5, 0.5, 0.5)
			
			ent.template = file.get_named_attribute_value_safe("template")
			ent.type = file.get_named_attribute_value_safe("type")
			ent.param0 = file.get_named_attribute_value_safe("param0")
			ent.param1 = file.get_named_attribute_value_safe("param1")
			ent.param2 = file.get_named_attribute_value_safe("param2")
			ent.param3 = file.get_named_attribute_value_safe("param3")
			ent.param4 = file.get_named_attribute_value_safe("param4")
			ent.param5 = file.get_named_attribute_value_safe("param5")
			
			# For Carambola extensions
			if (globals.options.enable_carambola_extensions):
				var n = file.get_named_attribute_value_safe("_Name")
				if (n): ent.editor_name = n
			
			$Segment.add_child(ent)
			objects.append(ent)
		
		# Load a decal
		elif (objectType == "decal"):
			var ent = EDecal.new()
			
			var pos = file.get_named_attribute_value_safe("pos").split_floats(" ")
			if (len(pos) == 3):
				ent.position = Vector3(pos[0], pos[1], pos[2])
			else:
				ent.position = Vector3(0.5, 0.5, 0.5)
			
			var size = file.get_named_attribute_value_safe("size").split_floats(" ")
			if (len(size) == 2):
				ent.size = Vector2(size[0], size[1])
			else:
				ent.size = Vector2(0.5, 0.5)
			
			var tile = file.get_named_attribute_value_safe("tile")
			if (tile):
				ent.decal = int(tile)
			
			if (file.get_named_attribute_value_safe("color") != ""):
				ent.colourise = true
				
				var colour = file.get_named_attribute_value_safe("color").split_floats(" ")
				if (len(colour) == 3):
					ent.colour = Color(colour[0], colour[1], colour[2], 1.0)
				elif (len(colour) == 4):
					ent.colour = Color(colour[0], colour[1], colour[2], colour[3])
				else:
					ent.colour = Color(0.5, 0.5, 0.5, 1.0)
			
			# For Carambola extensions
			if (globals.options.enable_carambola_extensions):
				var n = file.get_named_attribute_value_safe("_Name")
				if (n): ent.editor_name = n
			
			$Segment.add_child(ent)
			objects.append(ent)
		
		else:
			not_loaded_count += 1
			print("Note: Did not load object of type " + objectType)
	
	if (not_loaded_count > 0):
		print("Did not load " + str(not_loaded_count) + " incompatible objects.")
	else:
		print("Loaded segment at \'" + path + "\' successfully.")

## ####################
## Actually doing stuff
## ####################

func free_object():
	if (globals.selection):
		globals.selection.free()
		globals.selection = null
		gui.log_event("Freed the active obstacle!")
	else:
		gui.log_event("Error: No object has been selected!")

func new_box():
	var newBox = EBox.new()
	
	$Segment.add_child(newBox)
	objects.append(newBox)
	globals.set_active(newBox)
	
	gui.log_event("Created 1 box(es).")

func new_obstacle():
	var newObs = EObstacle.new()
	
	$Segment.add_child(newObs)
	objects.append(newObs)
	globals.set_active(newObs)
	
	gui.log_event("Created 1 obstacle(s).")

func new_decal():
	var newDec = EDecal.new()
	
	$Segment.add_child(newDec)
	objects.append(newDec)
	globals.set_active(newDec)
	
	gui.log_event("Created 1 decals(s).")

func load_templates(path : String):
	globals.load_templates(path)
	gui.log_event("Loaded templates file from '" + path + "'.")

func close_segment():
	# This actually deletes the segment
	print("Closing segment...")
	globals.set_active(null)
	
	for ent in objects:
		if (is_instance_valid(ent)):
			ent.free()
	
	objects = []
