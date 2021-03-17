extends Control

var prop : String = ""
var hold

func _ready():
	$label.text = prop.capitalize()
	
	if (globals.selection):
		$value.text = str(globals.selection[prop].x) + " " + str(globals.selection[prop].y)
	
	hold = globals.selection

func _process(_delta):
	if (globals.selection == hold):
		var v = $value.text.split_floats(" ")
		if (len(v) == 2):
			globals.selection[prop] = Vector2(v[0], v[1])

func set_property(prop_new : String):
	self.prop = prop_new
