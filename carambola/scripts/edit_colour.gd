extends Control

var prop : String = ""
var last : Color
var hold

func _ready():
	$label.text = prop.capitalize()
	
	if (globals.selection):
		$value.color = globals.selection[prop]
	
	last = $value.color
	hold = globals.selection

func _process(_delta):
	if ($value.color != last):
		if (hold == globals.selection):
			globals.selection[prop] = $value.color
			globals.selection.set_update()
		last = $value.color

func set_property(prop_new : String):
	self.prop = prop_new
