extends Node

const app_version = ["2021", "03", "11", "Alpha"]

var selection
var selectionChanged : bool = false
var scene_lock : bool = false
var scene_locker = null

var seg_size : Vector3 = Vector3()
var seg_template : String = ""

func set_active(object : Node):
	self.selection = object
	self.selectionChanged = true


##  ##############  ##
##  DEPRECATED!!!!  ##
##  ##############  ##

# Sets a strong lock on the scene
func setSceneLock(locker):
	if (!scene_locker):
		scene_locker = locker
		scene_lock = true

# Releases the lock on the scene
func releaseSceneLock(locker):
	if (locker == scene_locker):
		scene_lock = false
		scene_locker = null
	else:
		print("Impostor!")

# Gets weather the scene is locked
func isSceneLock():
	return scene_lock
