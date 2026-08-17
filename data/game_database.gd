class_name GameDatabase
extends RefCounted

var units: Dictionary = {}
var buildings: Dictionary = {}

func _init() -> void:
	units.worker = _unit(&"worker", "Worker", 80, 4.2, 5, 1.3, 1.2, 0, {"food": 50}, 2.5, true, true, Color("f2c879"))
	units.swordsman = _unit(&"swordsman", "Swordsman", 150, 3.8, 22, 1.55, 1.0, 0, {"food": 60, "gold": 25}, 3.5, false, false, Color("74b9ff"))
	units.musketeer = _unit(&"musketeer", "Musketeer", 100, 3.3, 18, 8.0, 1.7, 13, {"food": 50, "gold": 45}, 4.5, false, false, Color("a29bfe"))
	buildings.town_hall = _building(&"town_hall", "Town Hall", Vector2i(5,5), 1200, {}, 1, [&"worker"], 10, Color("d8b36a"))
	buildings.house = _building(&"house", "House", Vector2i(3,3), 450, {"wood": 100}, 5, [], 10, Color("e9c46a"))
	buildings.barracks = _building(&"barracks", "Barracks", Vector2i(4,4), 800, {"wood": 180, "gold": 40}, 8, [&"swordsman", &"musketeer"], 0, Color("c97c5d"))

func _unit(uid: StringName, label: String, hp: float, speed: float, damage: float, range_: float, cooldown: float, projectile: float, price: Dictionary, time: float, gather: bool, build: bool, tint: Color) -> UnitData:
	var d := UnitData.new(); d.id=uid; d.display_name=label; d.max_health=hp; d.movement_speed=speed; d.attack_damage=damage; d.attack_range=range_; d.attack_cooldown=cooldown; d.projectile_speed=projectile; d.cost=price; d.training_time=time; d.can_gather=gather; d.can_build=build; d.color=tint; return d

func _building(uid: StringName, label: String, size: Vector2i, hp: float, price: Dictionary, time: float, roster: Array[StringName], cap: int, tint: Color) -> BuildingData:
	var d := BuildingData.new(); d.id=uid; d.display_name=label; d.footprint=size; d.max_health=hp; d.cost=price; d.construction_time=time; d.available_units=roster; d.population_cap=cap; d.color=tint; return d
