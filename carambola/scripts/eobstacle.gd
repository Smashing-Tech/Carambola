extends EBase

class_name EObstacle

# Sub-components
const _Properties = ["editor_name", "position", "type", "template", "param0", "param1", "param2", "param3", "param4", "param5", "param6"]
var _box : MeshInstance = null
var timeSinceLastPhysicsUpdate : float = 0.0

# Elements
var editor_name : String = "Obstacle" + str(randi() % 1000)
var position : Vector3 = Vector3()
var template : String = ""
var type : String = ""

# Params
var param0 : String = ""
var param1 : String = ""
var param2 : String = ""
var param3 : String = ""
var param4 : String = ""
var param5 : String = ""
var param6 : String = ""

func _ready():
	globals.selection = self

func _physics_process(delta):
	if (needs_update):
		self.updateThis()
		needs_update = false

func updateThis():
	var size : Vector3 = Vector3(0.25, 0.5, 0.25)
	
	if (_box):
		_box.free()
	
	_box = MeshInstance.new()
	_box.translation = position + Vector3(0.0, 0.5, 0.0)
	_box.mesh = PrismMesh.new()
	_box.mesh.size = size * 2.0
	
	var _col = ClickableStaticBody.new()
	var box = BoxShape.new()
	box.set_extents(size)
	var shape = _col.create_shape_owner(box)
	_col.shape_owner_add_shape(shape, box)
	_box.add_child(_col)
	
	self.add_child(_box)

func set_active():
	globals.selection = self

func asXMLElement():
	var s = "<obstacle " 
	s += "pos=\"" + str(position.x) + " " + str(position.y) + " " + str(position.z) + "\" "
	if (type):
		s += "type=\"" + type + "\" "
	if (template):
		s += "template=\"" + template + "\" "
	for i in range(0, 6):
		if (self["param" + str(i)]):
			s += "param" + str(i) + "=\"" + self["param" + str(i)] + "\" "
	s += "/>"
	
	return s
