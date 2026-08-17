class_name WorldResource
extends StaticBody3D
var resource_type:="wood"
var amount:=500
func setup(kind:String,quantity:int)->void:
	resource_type=kind; amount=quantity
	var mesh_instance:=MeshInstance3D.new(); var mat:=StandardMaterial3D.new()
	if kind=="wood":
		var mesh:=CylinderMesh.new(); mesh.top_radius=.35; mesh.bottom_radius=.5; mesh.height=3.5; mesh_instance.mesh=mesh; mesh_instance.position.y=1.75; mat.albedo_color=Color("5b8c4a")
	else:
		var mesh:=SphereMesh.new(); mesh.radius=1.2; mesh.height=1.6; mesh_instance.mesh=mesh; mesh_instance.position.y=.7; mat.albedo_color=Color("e0b83e")
	mesh_instance.material_override=mat; add_child(mesh_instance)
	var collision:=CollisionShape3D.new(); var shape:=SphereShape3D.new(); shape.radius=1.0; collision.shape=shape; collision.position.y=1; add_child(collision)
func harvest(request:int)->int:
	var result:=mini(request,amount); amount-=result
	if amount<=0: queue_free()
	return result

