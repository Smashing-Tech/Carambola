extends Control

onready var s_EditString : PackedScene = preload("res://scenes/edit_string.tscn")
onready var s_EditBool : PackedScene = preload("res://scenes/edit_bool.tscn")
onready var s_EditVector : PackedScene = preload("res://scenes/edit_vector.tscn")
onready var s_EditVector2 : PackedScene = preload("res://scenes/edit_vector2.tscn")
onready var s_EditInt : PackedScene = preload("res://scenes/edit_int.tscn")
onready var s_EditColour : PackedScene = preload("res://scenes/edit_colour.tscn")

var propertiesPanel
var segmentPanel

func _ready():
	$SegFile.add_filter("*.xml.mp3 ; Segment Files")
	$SegFile.add_filter("*.xml ; Segment Files")
	$SegLoad.add_filter("*.xml.mp3 ; Segment Files")
	$SegLoad.add_filter("*.xml ; Segment Files")
	$TemplateLoad.add_filter("templates.xml.mp3 ; Template Files")
	$TemplateLoad.add_filter("templates.xml ; Template Files")
	
	propertiesPanel = $Tabs/Properties
	segmentPanel = $Tabs/Seg
	
	# On android or html5, limit to user data
	if (OS.get_name() == "Android" or OS.get_name() == "HTML5"):
		$SegFile.access = FileDialog.ACCESS_USERDATA
		$SegLoad.access = FileDialog.ACCESS_USERDATA
	
	$About/About.text = "Carambola Level Editor (version " + globals.app_version[0] + "-" + globals.app_version[1] + "-" + globals.app_version[2] + ")\n\nCopyright (C) 2021 Knot126 and other contributours. Please see MIT \nlicence.\n\nCarambola is made with the intent that it will be useful, but there is \nABOSLUTELY NO WARRANTY INCLUDED.\n\nThanks! (Click outside to make this dissappear.)"

func update():
	# This is what is done when a selection is changed (eg how the UI should 
	# update to addomidate a diffrent selection)
	if (!globals.selection):
		$Tabs/Properties/_Container.free()
		
		var container = Node.new()
		container.name = "_Container"
		$Tabs/Properties.add_child(container)
	
	if (globals.selection and globals.selectionChanged):
		# Free the old properties and make new container
		$Tabs/Properties/_Container.free()
		
		var container = Control.new()
		container.name = "_Container"
		
		# x-Position of the next property
		var x_pos = 10
		
		# Create a panel for each of the new properties
		for prop in globals.selection._Properties:
			var el
			
			if (globals.selection[prop] is String):
				el = s_EditString.instance()
			elif (globals.selection[prop] is bool):
				el = s_EditBool.instance()
			elif (globals.selection[prop] is Vector3):
				el = s_EditVector.instance()
			elif (globals.selection[prop] is Vector2):
				el = s_EditVector2.instance()
			elif (globals.selection[prop] is int):
				el = s_EditInt.instance()
			elif (globals.selection[prop] is Color):
				el = s_EditColour.instance()
			
			if (el):
				el.set_property(prop)
				el.name = prop
				el.rect_position = Vector2(10, x_pos)
				x_pos += 60
				
				container.add_child(el)
		
		$Tabs/Properties.add_child(container)
		$Tabs/Properties/_Container.rect_position = Vector2(0, 0)
		
		# For boxes
		#if (globals.selection is EBox):
		#	propertiesPanel.get_node("Colour").color = globals.selection.colour
	
	# This is what is done with a known valid selection
	# This should mainly be setting things in the selected obstacle
	if (globals.selection):
		pass
	
	# This will update the segment panel
	var new_seg_size = segmentPanel.get_node("Size").text.split_floats(" ")
	if (len(new_seg_size) == 3):
		globals.seg_size = Vector3(new_seg_size[0], new_seg_size[1], new_seg_size[2])
	globals.seg_template = segmentPanel.get_node("Template").text
	
	self.update_size()

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

func show_template_select():
	$TemplateLoad.popup_centered()

func show_about():
	$About.popup_centered()

func show_options():
	$Options.popup_centered()
	$Options.on_show()

func set_output_and_show(output : String):
	$XML/Output.text = output
	$XML.popup_centered()

