extends Control

var prop : String = ""
var hold

func _ready():
	$label.text = prop.capitalize()
	
	if (globals.selection):
		$value.text = str(globals.selection[prop].x) + " " + str(globals.selection[prop].y) + " " + str(globals.selection[prop].z)
	
	hold = globals.selection

func _process(_delta):
	if (globals.selection == hold):
		var v = $value.text.split_floats(" ")
		if (len(v) == 3):
			globals.selection[prop] = Vector3(v[0], v[1], v[2])

func set_property(prop_new : String):
	self.prop = prop_new
