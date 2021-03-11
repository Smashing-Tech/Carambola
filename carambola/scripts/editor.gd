extends Spatial

var last_event
var cam
var gui
var objects = []

func _ready():
	cam = $Camera
	gui = $UI
	
	gui.get_node("Menubar").get_node("Objects").get_popup().connect("id_pressed", self, "handle_objects_menu")
	gui.get_node("Menubar").get_node("File").get_popup().connect("id_pressed", self, "handle_file_menu")
	gui.get_node("Menubar").get_node("Help").get_popup().connect("id_pressed", self, "handle_help_menu")
	gui.get_node("SegFile").connect("file_selected", self, "serialise_segment")
	gui.get_node("SegLoad").connect("file_selected", self, "load_segment")

func _input(event):
	last_event = event

func _physics_process(delta):
	if (globals.selection and not globals.isSceneLock()):
		gui.log_event(globals.selection.asXMLElement())
	else:
		pass
	
	gui.update()
	
	globals.selectionChanged = false
	
	self.camera_update(delta)

func camera_update(delta):
	cam.translation.z -= (Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")) * 5.0 * delta
	if (Input.is_key_pressed(KEY_TAB)):
		cam.rotation_degrees.z += (Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")) * 20.0 * delta

func handle_objects_menu(id):
	# Place a box
	if (id == 0):
		var newBox = EBox.new()
		
		$Segment.add_child(newBox)
		objects.append(newBox)
		globals.set_active(newBox)
		
		gui.log_event("Created 1 box(es).")
	
	# Place an obstacle
	if (id == 1):
		var newObs = EObstacle.new()
		
		$Segment.add_child(newObs)
		objects.append(newObs)
		globals.set_active(newObs)
		
		gui.log_event("Created 1 obstacle(s).")
	
	# Free an object
	if (id == 3):
		if (globals.selection):
			globals.selection.free()
			globals.selection = null
		else:
			gui.log_event("Error: No object has been selected!")

func handle_file_menu(id):
	if (id == 0):
		gui.show_load_select()
	
	if (id == 1):
		gui.show_file_select()
	
	if (id == 5):
		gui.set_output_and_show(self.segment_to_xml())

func handle_help_menu(id):
	if (id == 1):
		gui.show_about()

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
		if (obj):
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
	globals.selection = null
	self.backup_segment()
	for ent in objects: if (ent): ent.free()
	objects = []
	
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
			
			# Here is how it SHOULD be done once the segment panel is designed better:
			#var size = file.get_named_attribute_value_safe("size").split_floats(" ")
			#if (len(size) == 3):
			#	globals.seg_size = Vector3(size[0], size[1], size[2])
			#else:
			#	globals.seg_size = Vector3(12, 10, 16)
			#
			#globals.seg_template = file.get_named_attribute_value_safe("template")
			
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
				
				var tile = file.get_named_attribute_value_safe("visible")
				if (tile):
					ent.tile = int(tile)
				
				var colour = file.get_named_attribute_value_safe("color").split_floats(" ")
				if (len(colour) == 3):
					ent.colour = Color(colour[0], colour[1], colour[2], 1.0)
				elif (len(colour) == 4):
					ent.colour = Color(colour[0], colour[1], colour[2], colour[3])
				else:
					ent.colour = Color(0.5, 0.5, 0.5, 1.0)
			else:
				ent.visible = false
			
			if (file.get_named_attribute_value_safe("reflection") == "1"):
				ent.reflection = true
			else:
				ent.reflection = false
			
			self.add_child(ent)
			objects.append(ent)
		
		# Load an obstacle
		elif (objectType == "obstacle"):
			var ent = EObstacle.new()
			
			var pos = file.get_named_attribute_value_safe("pos").split_floats(" ")
			if (len(pos) == 3):
				ent.position = Vector3(pos[0], pos[1], pos[2])
			else:
				ent.position = Vector3(0.5, 0.5, 0.5)
			
			ent.template = file.get_named_attribute_value_safe("template")
			ent.type = file.get_named_attribute_value_safe("type")
			
			self.add_child(ent)
			objects.append(ent)
		
		else:
			not_loaded_count += 1
		
		# file.read()
	
	if (not_loaded_count > 0):
		gui.log_event("Did not load " + str(not_loaded_count) + " incompatible objects.")
	else:
		gui.log_event("Loaded segment at \'" + path + "\' successfully.")
