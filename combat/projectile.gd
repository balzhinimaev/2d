class_name RtsProjectile
extends Node3D
var target:Node3D; var damage:=1.0; var speed:=10.0
func setup(from:Vector3,p_target:Node3D,p_damage:float,p_speed:float)->void:
	global_position=from+Vector3.UP; target=p_target; damage=p_damage; speed=p_speed
	var m:=MeshInstance3D.new(); var s:=SphereMesh.new(); s.radius=.12; s.height=.24; m.mesh=s; var mat:=StandardMaterial3D.new(); mat.albedo_color=Color("ffd166"); mat.emission_enabled=true; mat.emission=mat.albedo_color; m.material_override=mat; add_child(m)
func _process(delta:float)->void:
	if not is_instance_valid(target):queue_free();return
	var destination:=target.global_position+Vector3.UP
	if global_position.distance_to(destination)<.35: target.take_damage(damage);queue_free();return
	global_position=global_position.move_toward(destination,speed*delta)
