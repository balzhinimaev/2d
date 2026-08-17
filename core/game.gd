extends Node

var database:=GameDatabase.new()
var navigation:=GridNavigation.new()
var world:Node3D
var camera:RtsCamera
var units:Node3D
var buildings:Node3D
var resources:Node3D
var selected:Array[Node3D]=[]
var economies=[{"wood":500,"food":500,"gold":300,"pop":0,"cap":20},{"wood":9999,"food":9999,"gold":9999,"pop":0,"cap":20}]
var drag_start:=Vector2.ZERO
var dragging:=false
var selection_box:ColorRect
var info:Label
var top_bar:Label
var actions:HBoxContainer
var debug_label:Label
var placement_id:StringName=&""
var preview:MeshInstance3D
var ai_time:=0.0
var game_over:=false

func _ready()->void:
	_build_world(); _build_ui(); _spawn_initial(); set_process_unhandled_input(true)

func _build_world()->void:
	world=Node3D.new(); world.name="World"; add_child(world)
	units=Node3D.new(); units.name="Units"; world.add_child(units); buildings=Node3D.new(); buildings.name="Buildings"; world.add_child(buildings); resources=Node3D.new(); resources.name="Resources"; world.add_child(resources)
	var ground:=MeshInstance3D.new(); var plane:=PlaneMesh.new(); plane.size=Vector2(124,124); ground.mesh=plane; var gm:=StandardMaterial3D.new(); gm.albedo_color=Color("75a85b"); ground.material_override=gm; world.add_child(ground)
	var ground_body:=StaticBody3D.new(); ground_body.collision_layer=1; var shape:=CollisionShape3D.new(); var box:=BoxShape3D.new(); box.size=Vector3(124,.2,124); shape.shape=box; shape.position.y=-.1; ground_body.add_child(shape); world.add_child(ground_body)
	# River and rocky ridge mirror the blocked navigation cells.
	_make_box(Vector3(0,.06,0),Vector3(10,.12,124),Color("46a9cf"))
	_make_box(Vector3(-35,1,20),Vector3(26,2,10),Color("77766b"))
	for p in [Vector3(-48,0,-45),Vector3(-42,0,-38),Vector3(-35,0,-47),Vector3(-28,0,-36),Vector3(32,0,38),Vector3(42,0,43)]: _spawn_resource("wood",p)
	for p in [Vector3(-25,0,-30),Vector3(28,0,35)]: _spawn_resource("gold",p)
	var light:=DirectionalLight3D.new(); light.rotation_degrees=Vector3(-55,-30,0); light.shadow_enabled=true; light.light_energy=1.1; world.add_child(light)
	var env:=WorldEnvironment.new(); var e:=Environment.new(); e.background_mode=Environment.BG_COLOR; e.background_color=Color("9ed8e8"); e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR; e.ambient_light_color=Color("d8ecff"); e.ambient_light_energy=0.55; env.environment=e; world.add_child(env)
	camera=RtsCamera.new(); world.add_child(camera)

func _make_box(pos:Vector3,size_:Vector3,color:Color)->void:
	var m:=MeshInstance3D.new(); var b:=BoxMesh.new(); b.size=size_; m.mesh=b; m.position=pos; var mat:=StandardMaterial3D.new(); mat.albedo_color=color; m.material_override=mat; world.add_child(m)

func _spawn_initial()->void:
	spawn_building(&"town_hall",0,Vector3(-42,0,0),true); spawn_building(&"town_hall",1,Vector3(42,0,0),true); spawn_building(&"barracks",1,Vector3(35,0,12),true)
	for i in 4: spawn_unit(&"worker",0,Vector3(-48+i*2,0,8))
	for i in 3: spawn_unit(&"swordsman",0,Vector3(-43+i*2,0,-9)); spawn_unit(&"swordsman",1,Vector3(39+i*2,0,-9))

func spawn_unit(id:StringName,owner:int,pos:Vector3)->RtsUnit:
	var u:=RtsUnit.new(); units.add_child(u); u.global_position=pos; u.setup(database.units[id],owner,self); u.died.connect(_on_unit_died); economies[owner].pop+=u.data.population; return u
func spawn_building(id:StringName,owner:int,pos:Vector3,built:bool)->RtsBuilding:
	var b:=RtsBuilding.new(); buildings.add_child(b); b.global_position=pos; b.setup(database.buildings[id],owner,self,built); b.died.connect(_on_building_died)
	if built: economies[owner].cap+=b.data.population_cap
	return b
func _spawn_resource(kind:String,pos:Vector3)->void: var r:=WorldResource.new(); resources.add_child(r); r.global_position=pos; r.setup(kind,500)
func spawn_projectile(source:RtsUnit,target:Node3D,damage:float,speed:float)->void: var p:=RtsProjectile.new(); world.add_child(p); p.setup(source.global_position,target,damage,speed)

func _build_ui()->void:
	var canvas:=CanvasLayer.new(); add_child(canvas)
	top_bar=Label.new(); top_bar.position=Vector2(20,14); top_bar.add_theme_font_size_override("font_size",22); canvas.add_child(top_bar)
	info=Label.new(); info.position=Vector2(20,625); info.add_theme_font_size_override("font_size",18); canvas.add_child(info)
	actions=HBoxContainer.new(); actions.position=Vector2(300,625); canvas.add_child(actions)
	selection_box=ColorRect.new(); selection_box.color=Color(0.2,0.8,1,0.2); selection_box.mouse_filter=Control.MOUSE_FILTER_IGNORE; selection_box.visible=false; canvas.add_child(selection_box)
	debug_label=Label.new(); debug_label.position=Vector2(1040,20); debug_label.visible=false; canvas.add_child(debug_label)
	var help:=Label.new(); help.position=Vector2(20,48); help.text="WASD/edge: camera | wheel: zoom | LMB: select | RMB: order | F3: debug | Esc: pause"; canvas.add_child(help)

func _process(delta:float)->void:
	_update_ui(); _update_preview(); ai_time+=delta
	if ai_time>8 and not game_over: ai_time=0; _ai_step()
	if Input.is_action_just_pressed("debug_overlay"): debug_label.visible=not debug_label.visible
	if Input.is_action_just_pressed("pause_game"): get_tree().paused=not get_tree().paused

func _update_ui()->void:
	var e=economies[0]; top_bar.text="WOOD %d     FOOD %d     GOLD %d     POPULATION %d / %d"%[e.wood,e.food,e.gold,e.pop,e.cap]
	debug_label.text="FPS: %d\nUnits: %d\nBuildings: %d"%[Engine.get_frames_per_second(),units.get_child_count(),buildings.get_child_count()]
	if selected.is_empty(): info.text="Select a unit or building"; _buttons([]); return
	var s=selected[0]; info.text="%s   HP: %d / %d"%[s.data.display_name,maxi(0,int(s.health)),int(s.data.max_health)]
	if s is RtsUnit and s.data.can_build: _buttons(["Build House","Build Barracks"])
	elif s is RtsBuilding and s.owner_id==0: var labels:Array[String]=[]; for id in s.data.available_units: labels.append("Train "+database.units[id].display_name); _buttons(labels)
	else:_buttons([])

func _buttons(labels:Array)->void:
	var old:Array[String]=[]; for c in actions.get_children(): old.append(c.text)
	if old==labels:return
	for c in actions.get_children():c.queue_free()
	for label in labels:
		var button:=Button.new(); button.text=label; actions.add_child(button)
		if label=="Build House":button.pressed.connect(begin_placement.bind(&"house"))
		elif label=="Build Barracks":button.pressed.connect(begin_placement.bind(&"barracks"))
		elif label.begins_with("Train "): var id:StringName=&"worker" if label.ends_with("Worker") else (&"swordsman" if label.ends_with("Swordsman") else &"musketeer"); button.pressed.connect(_train.bind(id))

func begin_placement(id:StringName)->void:
	placement_id=id; preview=MeshInstance3D.new(); var box:=BoxMesh.new(); var d:BuildingData=database.buildings[id]; box.size=Vector3(d.footprint.x*1.7,2,d.footprint.y*1.7); preview.mesh=box; world.add_child(preview)
func _update_preview()->void:
	if placement_id==&"" or not is_instance_valid(preview):return
	var point:=mouse_ground(); preview.position=point+Vector3.UP; var valid:=navigation.can_place(point,database.buildings[placement_id].footprint); var mat:=StandardMaterial3D.new(); mat.albedo_color=Color(0.2,1,0.3,.45) if valid else Color(1,.15,.15,.45); mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA; preview.material_override=mat
func _train(id:StringName)->void:
	if not selected.is_empty() and selected[0] is RtsBuilding:selected[0].enqueue(id)

func _unhandled_input(event:InputEvent)->void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.pressed:
			if placement_id!=&"": _place(); get_viewport().set_input_as_handled(); return
			drag_start=event.position; dragging=true; selection_box.position=drag_start; selection_box.size=Vector2.ZERO; selection_box.visible=true
		else: dragging=false; selection_box.visible=false; _finish_selection(event.position,Input.is_key_pressed(KEY_SHIFT))
	elif event is InputEventMouseMotion and dragging:
		selection_box.position=Vector2(minf(drag_start.x,event.position.x),minf(drag_start.y,event.position.y)); selection_box.size=(event.position-drag_start).abs()
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_RIGHT and event.pressed:_issue_order(event.position)

func _finish_selection(end:Vector2,additive:bool)->void:
	if not additive:_clear_selection()
	var rect:=Rect2(Vector2(minf(drag_start.x,end.x),minf(drag_start.y,end.y)),(end-drag_start).abs())
	if rect.size.length()<8: rect=Rect2(end-Vector2(8,8),Vector2(16,16))
	for u in units.get_children(): if u.owner_id==0 and rect.has_point(camera.unproject_position(u.global_position+Vector3.UP)): _select(u)
	for b in buildings.get_children(): if b.owner_id==0 and rect.has_point(camera.unproject_position(b.global_position+Vector3.UP)): _select(b)
func _select(n:Node3D)->void: if not selected.has(n):selected.append(n);n.set_selected(true)
func _clear_selection()->void: for n in selected:if is_instance_valid(n):n.set_selected(false);selected.clear()

func _issue_order(screen:Vector2)->void:
	if selected.is_empty():return
	var hit:=raycast(screen); var collider=hit.get("collider"); var destination:Vector3=hit.get("position",mouse_ground())
	var controllable:Array[RtsUnit]=[]; for n in selected:if n is RtsUnit:controllable.append(n)
	var cols:=ceili(sqrt(controllable.size())); var index:=0
	for u in controllable:
		if collider is WorldResource:u.gather(collider)
		elif (collider is RtsUnit or collider is RtsBuilding) and collider.owner_id!=0:u.attack(collider)
		else: var offset:=Vector3((index%cols-(cols-1)*.5)*2,0,(index/cols)*2);u.move_to(destination+offset);index+=1

func _place()->void:
	var point:=mouse_ground(); var d:BuildingData=database.buildings[placement_id]
	if navigation.can_place(point,d.footprint) and try_spend(0,d.cost,0):
		var b:=spawn_building(placement_id,0,point,false)
		for n in selected:if n is RtsUnit and n.data.can_build:n.build(b);break
	preview.queue_free();placement_id=&""
func raycast(screen:Vector2)->Dictionary:
	var from:=camera.project_ray_origin(screen); return camera.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from,from+camera.project_ray_normal(screen)*500))
func mouse_ground()->Vector3:
	var mouse:=get_viewport().get_mouse_position(); var origin:=camera.project_ray_origin(mouse); var direction:=camera.project_ray_normal(mouse); var t:float=-origin.y/direction.y; return origin+direction*t

func try_spend(owner:int,cost:Dictionary,population:int)->bool:
	var e=economies[owner]
	if e.pop+population>e.cap:return false
	for key in cost:if e.get(key,0)<cost[key]:return false
	for key in cost:e[key]-=cost[key]
	return true
func add_resource(owner:int,kind:String,amount:int)->void:economies[owner][kind]=economies[owner].get(kind,0)+amount
func building_completed(b:RtsBuilding)->void:economies[b.owner_id].cap+=b.data.population_cap
func _on_unit_died(u:RtsUnit)->void:economies[u.owner_id].pop-=u.data.population;selected.erase(u)
func _on_building_died(b:RtsBuilding)->void:
	selected.erase(b)
	if b.data.id==&"town_hall":_end_game(b.owner_id!=0)
func _end_game(victory:bool)->void:
	game_over=true;var label:=Label.new();label.text="VICTORY" if victory else "DEFEAT";label.position=Vector2(500,280);label.add_theme_font_size_override("font_size",64);add_child(label);var restart:=Button.new();restart.text="Restart";restart.position=Vector2(570,360);restart.pressed.connect(func():get_tree().reload_current_scene());add_child(restart)
func _ai_step()->void:
	var military:Array[RtsUnit]=[]
	for u in units.get_children():if u.owner_id==1 and not u.data.can_gather:military.append(u)
	var barracks:RtsBuilding
	for b in buildings.get_children():if b.owner_id==1 and b.data.id==&"barracks":barracks=b
	if is_instance_valid(barracks):barracks.enqueue(&"swordsman")
	if military.size()>=4:
		var player_hall:Node3D
		for b in buildings.get_children():if b.owner_id==0 and b.data.id==&"town_hall":player_hall=b
		if is_instance_valid(player_hall):for u in military:u.attack(player_hall)
