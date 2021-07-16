# Carambola Developer Documentation

This file contains some remarks about Carambola's development and "software architecture." (The use of airquotes is VERY imporant there!)

**Note**: At the time I wrote Carambola, I was very hard anti-OOP mainly becuase I didn't understand a lot of it. Please consider this mindset when trying to understand this architecture.

## Organisation

The `assets` folder contains all of the assets, the `scripts` folder contains all of the gdscript files and `scenes` contains all of the scenes.

## User Interface

The UI was mainly split into differnet classes that are created per type of feild. That is, position is a vector, so it will use the `vector` type, etc. Each user interface element more or less mages itself and updates in parallel with the others by just being called on `_process`. All attributes of an entity that can be edited are kept in a list, and every time an entity is selected, the appropreaite elements are created or destroyed.

Most of the actual surrounding UI was not as well thought out and resides in a single `ui.gd` file.

### Input Conventions

The input of vectors are as space sperated decimal numbers, like Smash Hit does it. For example, `0.03 -1.6 2.25` and `17.4 6.2`.

## Entites

The base class entity is `EBase`, which just contains some basic update functionality.

The drawing and attribute storage are done in each obstacle.

Each elements implements the `asXMLElement` function, which returns a document fragment string that can be used on exporting the entity to a file.

### Attributes

The attributes (sometimes called `Elements` or `Properties`) are stored per entity and can be a subset of the standard types in Godot. Currently, these are:

  * bool (`edit_bool.gd`)
  * Color (`edit_colour.gd`)
  * int (`edit_int.gd`)
  * String (`edit_string.gd`)
  * Vector3 (`edit_vector.gd`)
  * Vector2 (`edit_vector2.gd`)

In a list, usually called `_Properties`, the editable properties for an entity are held. This list is important as it contains all the attributes that can be edited on the given entity, and is used to generate the UI elements that let the user edit properites.

The `_Properties` list allows a sort of polymorphim (not sure that's the right term?) for data, so we can access the entites' data without really needing to know their type.

## Other Classes and Files

### `ClickableStaticBody`

A static body that sets itself active when clicked on.

### `editor.gd`

The main editor file. Contains startup, shutdown, debug functions, updating UI, handling menus, serialisation and loading segments, entity management, entity creation and a lot of other stuff that should probably be done elsewhere.

### `global.gd`

Contains all of the global state for the editor and some utility functions. For example, the segement size is stored here.

  * The options variable is stored here, as well as the functions for loading and saving settings to disk.
  * Templates and loading/clearing all of them is also done here.

### `utils.gd`

Contains one utlity function: `utils.unpack_colour_string`, which converts a string to a colour.
