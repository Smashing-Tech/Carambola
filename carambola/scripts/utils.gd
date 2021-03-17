# Class containing some helper functions

extends Node

func unpack_colour_string(s : String):
	var colour = s.split_floats(" ")
	if (len(colour) == 3):
		return Color(colour[0], colour[1], colour[2], 1.0)
	elif (len(colour) == 4):
		return Color(colour[0], colour[1], colour[2], colour[3])
	else:
		return Color(0.5, 0.5, 0.5, 1.0)
