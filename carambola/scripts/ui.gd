extends Control

var propertiesPanel
var segmentPanel

func _ready():
	$SegFile.add_filter("*.xml.mp3 ; Segment Files")
	$SegFile.add_filter("*.xml ; Segment Files")
	$SegFile.current_dir = "user://"
	$SegFile.current_path = "user://"
	
	$SegLoad.add_filter("*.xml.mp3 ; Segment Files")
	$SegLoad.add_filter("*.xml ; Segment Files")
	$SegLoad.current_dir = "user://"
	$SegLoad.current_path = "user://"
	
	propertiesPanel = $Tabs/Properties
	segmentPanel = $Tabs/Seg
	
	# On android or html5, limit to user data
	if (OS.get_name() == "Android" or OS.get_name() == "HTML5"):
		$SegFile.access = FileDialog.ACCESS_USERDATA
		$SegLoad.access = FileDialog.ACCESS_USERDATA

func update():
	# This will update what is visible to the user
	self.update_type()
	
	# This is what is done when a selection is changed (eg how the UI should 
	# update to addomidate a diffrent selection)
	if (globals.selection and globals.selectionChanged):
		propertiesPanel.get_node("LName").text = globals.selection.editor_name
		propertiesPanel.get_node("Pos").text = str(globals.selection.position.x) + " " + str(globals.selection.position.y) + " " + str(globals.selection.position.z)
		propertiesPanel.get_node("Template").text = globals.selection.template
		
		# For boxes
		if (globals.selection is EBox):
			propertiesPanel.get_node("Size").text = str(globals.selection.size.x) + " " + str(globals.selection.size.y) + " " + str(globals.selection.size.z)
			propertiesPanel.get_node("Visible").pressed = globals.selection.visible
			propertiesPanel.get_node("Tile").text = str(globals.selection.tile)
			propertiesPanel.get_node("Colour").color = globals.selection.colour
		
		# For obstacles
		if (globals.selection is EObstacle):
			propertiesPanel.get_node("Type").text = globals.selection.type
	
	# This is what is done with a known valid selection
	# This should mainly be setting things in the selected obstacle
	if (globals.selection):
		# Position
		var setPos = propertiesPanel.get_node("Pos").text.split_floats(" ")
		if (len(setPos) == 3):
			globals.selection.position = Vector3(setPos[0], setPos[1], setPos[2])
		
		# Template
		globals.selection.template = propertiesPanel.get_node("Template").text
		
		# Boxes
		if (globals.selection is EBox):
			var setSize = propertiesPanel.get_node("Size").text.split_floats(" ")
			if (len(setSize) == 3):
				globals.selection.size = Vector3(setSize[0], setSize[1], setSize[2])
			
			globals.selection.visible = propertiesPanel.get_node("Visible").pressed
			globals.selection.tile = int(propertiesPanel.get_node("Tile").text)
			globals.selection.colour = propertiesPanel.get_node("Colour").color
		
		if (globals.selection is EObstacle):
			globals.selection.type = propertiesPanel.get_node("Type").text
	
	# This will update the segment panel
	var new_seg_size = segmentPanel.get_node("Size").text.split_floats(" ")
	if (len(new_seg_size) == 3):
		globals.seg_size = Vector3(new_seg_size[0], new_seg_size[1], new_seg_size[2])
	globals.seg_template = segmentPanel.get_node("Template").text
	
	self.update_size()

func update_type():
	if (globals.selection):
		propertiesPanel.get_node("LName").visible = true
		
		if (globals.selection is EBox):
			propertiesPanel.get_node("LPos").visible = true
			propertiesPanel.get_node("Pos").visible = true
			propertiesPanel.get_node("LSize").visible = true
			propertiesPanel.get_node("Size").visible = true
			propertiesPanel.get_node("LType").visible = false
			propertiesPanel.get_node("Type").visible = false
			propertiesPanel.get_node("LTemplate").visible = true
			propertiesPanel.get_node("Template").visible = true
			propertiesPanel.get_node("Visible").visible = true
			propertiesPanel.get_node("LTile").visible = true
			propertiesPanel.get_node("Tile").visible = true
			propertiesPanel.get_node("LColour").visible = true
			propertiesPanel.get_node("Colour").visible = true
			# If the box is not visible then the data shouldn't be able to be
			# edited
			if (globals.selection.visible):
				propertiesPanel.get_node("Tile").editable = true
				propertiesPanel.get_node("Colour").disabled = false
			else:
				propertiesPanel.get_node("Tile").editable = false
				propertiesPanel.get_node("Colour").disabled = true
		elif (globals.selection is EObstacle):
			propertiesPanel.get_node("LPos").visible = true
			propertiesPanel.get_node("Pos").visible = true
			propertiesPanel.get_node("LSize").visible = false
			propertiesPanel.get_node("Size").visible = false
			propertiesPanel.get_node("LType").visible = true
			propertiesPanel.get_node("Type").visible = true
			propertiesPanel.get_node("LTemplate").visible = true
			propertiesPanel.get_node("Template").visible = true
			propertiesPanel.get_node("Visible").visible = false
			propertiesPanel.get_node("LTile").visible = false
			propertiesPanel.get_node("Tile").visible = false
			propertiesPanel.get_node("LColour").visible = false
			propertiesPanel.get_node("Colour").visible = false
		else:
			self.disable_all_properties()
	else:
		self.disable_all_properties()

func disable_all_properties():
	propertiesPanel.get_node("LPos").visible = false
	propertiesPanel.get_node("Pos").visible = false
	propertiesPanel.get_node("LSize").visible = false
	propertiesPanel.get_node("Size").visible = false
	propertiesPanel.get_node("LType").visible = false
	propertiesPanel.get_node("Type").visible = false
	propertiesPanel.get_node("LTemplate").visible = false
	propertiesPanel.get_node("Template").visible = false
	propertiesPanel.get_node("Visible").visible = false
	propertiesPanel.get_node("LTile").visible = false
	propertiesPanel.get_node("Tile").visible = false
	propertiesPanel.get_node("LColour").visible = false
	propertiesPanel.get_node("Colour").visible = false

func update_size():
	var vp_size = get_viewport().size
	
	$BottomBar.rect_position.y = vp_size.y - 20
	$Tabs.rect_position.x = vp_size.x - 230
	$Tabs.rect_size.y = vp_size.y - 60
	$Menubar.rect_size.x = vp_size.x
	$BottomBar.rect_size.x = vp_size.x

# The status bar is designed to replicate what blender does, just a lot more
# useful in this editor.
func log_event(string : String):
	$BottomBar/Status.text = string# + "\n"

func show_file_select():
	$SegFile.popup_centered()

func show_load_select():
	$SegLoad.popup_centered()

func show_about():
	$About.popup_centered()

func set_output_and_show(output : String):
	$XML/Output.text = output
	$XML.popup_centered()
