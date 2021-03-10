extends Spatial

func _ready():
	pass

func _physics_process(_delta):
	if (globals.selection == null):
		$Beat.translation = Vector3(0.0, -10.0, 0.0)
	else:
		$Beat.translation = globals.selection.position
