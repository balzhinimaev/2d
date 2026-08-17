class_name RtsCamera
extends Camera3D
var focus:=Vector3(-35,0,0)
func _ready()->void: projection=Camera3D.PROJECTION_ORTHOGONAL; size=34; rotation_degrees=Vector3(-55,-45,0); _sync()
func _process(delta:float)->void:
	var direction:=Input.get_vector("camera_left","camera_right","camera_up","camera_down")
	var mouse:=get_viewport().get_mouse_position(); var viewport:=get_viewport().get_visible_rect().size; var edge:=18.0
	if mouse.x<edge:direction.x-=1
	if mouse.x>viewport.x-edge:direction.x+=1
	if mouse.y<edge:direction.y-=1
	if mouse.y>viewport.y-edge:direction.y+=1
	var forward:=Vector3(-1,0,-1).normalized(); var right:=Vector3(1,0,-1).normalized(); focus+=(right*direction.x+forward*direction.y)*22*delta*(size/34.0); focus.x=clampf(focus.x,-52,52); focus.z=clampf(focus.z,-52,52); _sync()
func _unhandled_input(event:InputEvent)->void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index==MOUSE_BUTTON_WHEEL_UP:size=clampf(size-3,16,55)
		if event.button_index==MOUSE_BUTTON_WHEEL_DOWN:size=clampf(size+3,16,55)
func _sync()->void: global_position=focus+Vector3(22,28,22); look_at(focus,Vector3.UP)

