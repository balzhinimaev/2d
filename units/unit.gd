class_name RtsUnit
extends CharacterBody3D

signal died(unit: RtsUnit)
signal selection_changed(unit: RtsUnit)

enum OrderType { IDLE, MOVE, ATTACK, GATHER, BUILD }
var data: UnitData
var owner_id := 0
var health := 1.0
var selected := false
var order := OrderType.IDLE
var path := PackedVector3Array()
var path_index := 0
var target: Node3D
var cooldown := 0.0
var cargo_type := ""
var cargo := 0
var game: Node
var visual: Node3D
var ring: MeshInstance3D
var animator: AnimationPlayer

func setup(p_data: UnitData, p_owner: int, p_game: Node) -> void:
	data=p_data; owner_id=p_owner; game=p_game; health=data.max_health
	collision_layer = 1 << (owner_id + 1); collision_mask = 1
	_build_visual()

func _build_visual() -> void:
	visual=Node3D.new(); visual.name="Visual"; add_child(visual)
	var body:=MeshInstance3D.new(); var capsule:=CapsuleMesh.new(); capsule.height=1.7; capsule.radius=0.38; body.mesh=capsule; body.position.y=0.9
	var mat:=StandardMaterial3D.new(); mat.albedo_color=data.color.darkened(0.35) if owner_id==1 else data.color; body.material_override=mat; visual.add_child(body)
	var head:=MeshInstance3D.new(); var sphere:=SphereMesh.new(); sphere.radius=0.3; sphere.height=0.6; head.mesh=sphere; head.position.y=1.85; head.material_override=mat; visual.add_child(head)
	ring=MeshInstance3D.new(); var torus:=TorusMesh.new(); torus.inner_radius=0.55; torus.outer_radius=0.67; ring.mesh=torus; ring.position.y=0.05; var rm:=StandardMaterial3D.new(); rm.albedo_color=Color("55ff88"); rm.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED; ring.material_override=rm; ring.visible=false; add_child(ring)
	var shape:=CollisionShape3D.new(); var cs:=CapsuleShape3D.new(); cs.height=1.8; cs.radius=0.42; shape.shape=cs; shape.position.y=0.9; add_child(shape)
	animator=AnimationPlayer.new(); animator.name="AnimationPlayer"; add_child(animator); _make_animations()

func _make_animations() -> void:
	var lib:=AnimationLibrary.new()
	for state in ["idle","walk","attack","hit","death","gather","build"]:
		var a:=Animation.new(); a.length=0.55; a.loop_mode=Animation.LOOP_LINEAR if state in ["idle","walk"] else Animation.LOOP_NONE
		var track:=a.add_track(Animation.TYPE_VALUE); a.track_set_path(track, NodePath("Visual:rotation:z")); a.track_insert_key(track,0.0,0.0)
		var amplitude:=0.04 if state=="idle" else (0.13 if state=="walk" else 0.35)
		a.track_insert_key(track,0.27,amplitude); a.track_insert_key(track,0.55,0.0); lib.add_animation(state,a)
	animator.add_animation_library("",lib); animator.play("idle")

func set_selected(value: bool) -> void:
	selected=value; ring.visible=value; selection_changed.emit(self)

func move_to(destination: Vector3) -> void:
	target=null; order=OrderType.MOVE; path=game.navigation.path(global_position,destination); path_index=1; animator.play("walk")

func attack(enemy: Node3D) -> void:
	target=enemy; order=OrderType.ATTACK

func gather(node: Node3D) -> void:
	if not data.can_gather: return
	target=node; order=OrderType.GATHER

func build(building: Node3D) -> void:
	if not data.can_build: return
	target=building; order=OrderType.BUILD

func _physics_process(delta: float) -> void:
	if health<=0: return
	cooldown=maxf(0,cooldown-delta)
	match order:
		OrderType.MOVE: _follow_path(delta)
		OrderType.ATTACK: _combat(delta)
		OrderType.GATHER: _gather(delta)
		OrderType.BUILD: _build(delta)

func _follow_path(_delta: float) -> void:
	if path_index>=path.size(): _idle(); return
	var waypoint:=path[path_index]; var flat:=waypoint-global_position; flat.y=0
	if flat.length()<0.35: path_index+=1; return
	velocity=flat.normalized()*data.movement_speed; visual.rotation.y=atan2(velocity.x,velocity.z); move_and_slide()

func _move_near(destination: Vector3, stop_range: float) -> bool:
	var flat:=destination-global_position; flat.y=0
	if flat.length()<=stop_range: velocity=Vector3.ZERO; return true
	if path.is_empty() or path_index>=path.size(): path=game.navigation.path(global_position,destination); path_index=1
	_follow_path(0); return false

func _combat(_delta: float) -> void:
	if not is_instance_valid(target) or target.get("health")<=0: _idle(); return
	if not _move_near(target.global_position,data.attack_range): return
	visual.look_at(Vector3(target.global_position.x,visual.global_position.y,target.global_position.z),Vector3.UP,true)
	if cooldown<=0:
		cooldown=data.attack_cooldown; animator.play("attack")
		if data.projectile_speed>0: game.spawn_projectile(self,target,data.attack_damage,data.projectile_speed)
		else: target.take_damage(data.attack_damage)

func _gather(_delta: float) -> void:
	if not is_instance_valid(target) or target.get("amount")<=0: _idle(); return
	if not _move_near(target.global_position,1.6): return
	if cooldown<=0:
		cooldown=1.0; animator.play("gather"); var gained:int=target.harvest(10); game.add_resource(owner_id,target.resource_type,gained)

func _build(delta: float) -> void:
	if not is_instance_valid(target) or target.get("complete"): _idle(); return
	if not _move_near(target.global_position,2.5): return
	animator.play("build"); target.add_construction(delta)

func _idle() -> void:
	order=OrderType.IDLE; velocity=Vector3.ZERO; path=PackedVector3Array(); animator.play("idle")

func take_damage(amount: float) -> void:
	health-=amount
	if health<=0:
		order=OrderType.IDLE; animator.play("death"); collision_layer=0; collision_mask=0; died.emit(self); var tween:=create_tween(); tween.tween_property(visual,"rotation:z",PI/2,0.5); tween.tween_interval(2); tween.tween_callback(queue_free)
	else: animator.play("hit")

