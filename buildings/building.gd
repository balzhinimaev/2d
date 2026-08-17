class_name RtsBuilding
extends StaticBody3D

signal died(building: RtsBuilding)
var data: BuildingData
var owner_id:=0
var health:=1.0
var complete:=true
var construction:=1.0
var queue:Array[StringName]=[]
var queue_time:=0.0
var game:Node
var selected:=false
var visual:MeshInstance3D
var ring:MeshInstance3D

func setup(p_data:BuildingData,p_owner:int,p_game:Node,built:=true)->void:
	data=p_data; owner_id=p_owner; game=p_game; complete=built; construction=1.0 if built else 0.05; health=data.max_health*construction; _build_visual(); game.navigation.set_building_blocked(global_position,data.footprint,true)

func _build_visual()->void:
	visual=MeshInstance3D.new(); var box:=BoxMesh.new(); box.size=Vector3(data.footprint.x*1.7,3.2,data.footprint.y*1.7); visual.mesh=box; visual.position.y=1.6
	var mat:=StandardMaterial3D.new(); mat.albedo_color=data.color.darkened(0.35) if owner_id==1 else data.color; visual.material_override=mat; add_child(visual)
	var shape:=CollisionShape3D.new(); var cs:=BoxShape3D.new(); cs.size=box.size; shape.shape=cs; shape.position=visual.position; add_child(shape)
	ring=MeshInstance3D.new(); var plane:=PlaneMesh.new(); plane.size=Vector2(data.footprint.x*2.0,data.footprint.y*2.0); ring.mesh=plane; ring.position.y=0.04; var rm:=StandardMaterial3D.new(); rm.albedo_color=Color(0.2,1,0.4,0.3); rm.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA; ring.material_override=rm; ring.visible=false; add_child(ring); _refresh_visual()

func set_selected(v:bool)->void: selected=v; ring.visible=v
func add_construction(delta:float)->void:
	construction=minf(1.0,construction+delta/data.construction_time); health=data.max_health*construction; _refresh_visual()
	if construction>=1.0 and not complete: complete=true; game.building_completed(self)
func _refresh_visual()->void: if is_instance_valid(visual): visual.scale.y=maxf(0.08,construction)
func enqueue(unit_id:StringName)->bool:
	if not complete or not data.available_units.has(unit_id): return false
	if game.try_spend(owner_id,game.database.units[unit_id].cost,game.database.units[unit_id].population): queue.append(unit_id); return true
	return false
func _process(delta:float)->void:
	if queue.is_empty() or not complete:return
	var unit_data:UnitData=game.database.units[queue[0]]; queue_time+=delta
	if queue_time>=unit_data.training_time: queue_time=0; queue.pop_front(); game.spawn_unit(unit_data.id,owner_id,global_position+Vector3(data.footprint.x+2,0,0))
func take_damage(amount:float)->void:
	health-=amount
	if health<=0: game.navigation.set_building_blocked(global_position,data.footprint,false); died.emit(self); queue_free()

