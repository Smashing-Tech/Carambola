extends Node

class_name EObstacle

# Sub-components
const _Properties = ["editor_name", "position", "type", "template", "paramaters"]
var _box : MeshInstance = null
var timeSinceLastPhysicsUpdate : float = 0.0

# Elements
var editor_name : String = "Obstacle" + str(randi() % 1000)
var position : Vector3 = Vector3()
var template : String = ""
var type : String = ""
var paramaters : String = ""

func _ready():
	globals.selection = self

func _physics_process(delta):
	timeSinceLastPhysicsUpdate += delta
	if (timeSinceLastPhysicsUpdate > 0.1):
		updateThis()
		timeSinceLastPhysicsUpdate = 0.0

func updateThis():
	var size : Vector3 = Vector3(0.25, 0.5, 0.25)
	
	if (_box):
		_box.free()
	
	_box = MeshInstance.new()
	_box.translation = position
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
	s += "/>"
	
	return s
