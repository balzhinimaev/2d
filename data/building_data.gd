class_name BuildingData
extends Resource

@export var id: StringName
@export var display_name := "Building"
@export var footprint := Vector2i(3, 3)
@export var max_health := 500.0
@export var cost: Dictionary = {}
@export var construction_time := 6.0
@export var available_units: Array[StringName] = []
@export var population_cap := 0
@export var color := Color.WHITE

