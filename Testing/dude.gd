extends KinematicBody

var spinnyBone = null

#TODO manipulate speed or auto if have plates, add toggle-constant push/for slow walk
#make accel to full speed slower
var max_speed = 500.0

var mouse_precision = 5
var mouse_sensitivity = 0.1
var max_cam_deg = 30

var velocity = Vector3.ZERO
var traySpinVector = Vector3.ZERO
var camXRotation = INF
var spinForce = INF

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Armature/Skeleton.physical_bones_start_simulation(["Bone.001"])
	spinnyBone = $Armature/Skeleton/Back
	
func _input(event):
	var trayForce = event.get_action_strength("mouse_left") - event.get_action_strength("mouse_right")
	if trayForce != 0:
		traySpinVector = get_global_transform().basis.x * trayForce
		
	if event is InputEventMouseMotion:
		if Vector2.ZERO.distance_to(event.relative) >= mouse_precision:
			spinForce = - deg2rad(event.relative.x * mouse_sensitivity)
			
			var camNewXRotation = $Camera.rotation_degrees.x - deg2rad(event.relative.y * mouse_sensitivity * max_speed)
			if camNewXRotation > max_cam_deg:
				camNewXRotation = max_cam_deg
			if camNewXRotation < -max_cam_deg:
				camNewXRotation = -max_cam_deg
			camXRotation = camNewXRotation
	
func _physics_process(_delta):
	var frontVector = get_global_transform().basis.z;
	var sideVector = get_global_transform().basis.x;

	var frontForce = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	var sideForce = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")

	velocity = Vector3.DOWN * 10

	if frontForce != 0:
		velocity += frontVector * _delta * frontForce * max_speed
	if sideForce != 0:
		velocity += sideVector * _delta * sideForce * max_speed
		
	if Vector3.ZERO != velocity:
		velocity = move_and_slide(velocity, Vector3.UP)
			
	if Vector3.ZERO != traySpinVector:
		spinnyBone.apply_impulse(traySpinVector * _delta * max_speed, Vector3.DOWN)
		traySpinVector = Vector3.ZERO
			
	if INF != camXRotation:
		$Camera.rotation_degrees.x = camXRotation
		camXRotation = INF
		
	if INF != spinForce:
		rotate_y(spinForce)
		spinnyBone.apply_impulse(sideVector if spinForce > 0 else -sideVector, Vector3.DOWN / 2.5)
		spinForce = INF

