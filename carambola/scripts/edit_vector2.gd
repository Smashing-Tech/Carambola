extends Control

var prop : String = ""
var last : String
var hold

func _ready():
	$label.text = prop.capitalize()
	
	if (globals.selection):
		$value.text = str(globals.selection[prop].x) + " " + str(globals.selection[prop].y)
	
	last = $value.text
	hold = globals.selection

func _process(_delta):
	if ($value.text != last):
		if (globals.selection == hold):
			var v = $value.text.split_floats(" ")
			if (len(v) == 2):
				globals.selection[prop] = Vector2(v[0], v[1])
				globals.selection.set_update()
		last = $value.text

func set_property(prop_new : String):
	self.prop = prop_new
