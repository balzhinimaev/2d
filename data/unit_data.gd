class_name UnitData
extends Resource

@export var id: StringName
@export var display_name := "Unit"
@export var max_health := 100.0
@export var movement_speed := 4.0
@export var attack_damage := 10.0
@export var attack_range := 1.5
@export var attack_cooldown := 1.0
@export var projectile_speed := 0.0
@export var cost: Dictionary = {}
@export var training_time := 3.0
@export var population := 1
@export var can_gather := false
@export var can_build := false
@export var color := Color.WHITE

