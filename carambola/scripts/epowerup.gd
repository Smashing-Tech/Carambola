extends EBase

class_name EPowerUp

# Sub-components
const _Properties = ["editor_name", "position", "type"]
var mesh_instance : MeshInstance = null

# Elements
var editor_name : String = "Decal" + str(randi() % 1000)
var position : Vector3 = Vector3()
var type : String = "ballfrenzy"

func _ready():
	globals.selection = self

func _physics_process(delta):
	if (needs_update):
		self.updateThis()
		needs_update = false

func updateThis():
	if (mesh_instance):
		mesh_instance.free()
	
	mesh_instance = MeshInstance.new()
	mesh_instance.translation = position
	mesh_instance.mesh = QuadMesh.new()
	mesh_instance.mesh.size = Vector2(1.0, 1.0)
	
	var mat = SpatialMaterial.new()
	mat.albedo_texture = globals.get_decal(decal)
	mat.flags_transparent = true
	mesh_instance.set_surface_material(0, mat)
	
	var _col = ClickableStaticBody.new()
	var box = BoxShape.new()
	box.set_extents(Vector3(size.x, size.y, 0.0))
	var shape = _col.create_shape_owner(box)
	_col.shape_owner_add_shape(shape, box)
	mesh_instance.add_child(_col)
	
	self.add_child(mesh_instance)

func set_active():
	globals.selection = self

func asXMLElement():
	var s = "<decal " 
	s += "pos=\"" + str(position.x) + " " + str(position.y) + " " + str(position.z) + "\" "
	s += "size=\"" + str(size.x) + " " + str(size.y) + "\" "
	s += "tile=\"" + str(decal) + "\" "
	if (colourise):
		var cstr = ""
		cstr += str(colour.r) + " " + str(colour.g) + " " + str(colour.b)
		if (colour.a < 1.0):
			cstr += " " + str(colour.a)
		s += "color=\"" + cstr + "\" "
	s += "/>"
	
	return s
