class_name GridNavigation
extends RefCounted

const CELL := 2.0
const HALF := 30
var astar := AStarGrid2D.new()

func _init() -> void:
	astar.region = Rect2i(-HALF, -HALF, HALF*2+1, HALF*2+1)
	astar.cell_size = Vector2(CELL, CELL)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()
	# River with two readable crossings.
	for z in range(-HALF, HALF+1):
		if abs(z) > 4 and not (z >= 15 and z <= 18):
			for x in range(-2, 3): astar.set_point_solid(Vector2i(x,z), true)
	# Rocky ridge.
	for x in range(-24, -11):
		for z in range(8, 13): astar.set_point_solid(Vector2i(x,z), true)

func world_to_cell(p: Vector3) -> Vector2i:
	return Vector2i(roundi(p.x/CELL), roundi(p.z/CELL)).clamp(Vector2i(-HALF,-HALF), Vector2i(HALF,HALF))

func cell_to_world(p: Vector2i) -> Vector3:
	return Vector3(p.x*CELL, 0, p.y*CELL)

func path(from: Vector3, to: Vector3) -> PackedVector3Array:
	var a := world_to_cell(from); var b := world_to_cell(to)
	if astar.is_point_solid(b): b = nearest_free(b)
	var cells := astar.get_id_path(a,b)
	var result := PackedVector3Array()
	for c in cells: result.append(cell_to_world(c))
	return result

func nearest_free(p: Vector2i) -> Vector2i:
	for radius in range(1, 10):
		for x in range(p.x-radius,p.x+radius+1):
			for y in range(p.y-radius,p.y+radius+1):
				var q := Vector2i(x,y)
				if astar.region.has_point(q) and not astar.is_point_solid(q): return q
	return Vector2i.ZERO

func set_building_blocked(center: Vector3, footprint: Vector2i, blocked: bool) -> void:
	var c := world_to_cell(center)
	for x in range(c.x-footprint.x/2, c.x+(footprint.x+1)/2):
		for z in range(c.y-footprint.y/2, c.y+(footprint.y+1)/2):
			if astar.region.has_point(Vector2i(x,z)): astar.set_point_solid(Vector2i(x,z), blocked)

func can_place(center: Vector3, footprint: Vector2i) -> bool:
	var c := world_to_cell(center)
	for x in range(c.x-footprint.x/2, c.x+(footprint.x+1)/2):
		for z in range(c.y-footprint.y/2, c.y+(footprint.y+1)/2):
			var q := Vector2i(x,z)
			if not astar.region.has_point(q) or astar.is_point_solid(q): return false
	return true
