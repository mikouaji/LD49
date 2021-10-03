extends KinematicBody

const SPEED = 400.0
const SNEAK = 100.0

var max_speed = SPEED

var mouse_precision = 5
var mouse_sensitivity = 0.1
var max_cam_deg = 30

var velocity = Vector3.ZERO
var camXRotation = INF
var spinForce = INF

var newPos = Vector3.INF

var RNG : RandomNumberGenerator

	
func init(_rng):
	RNG=_rng
	max_speed = SPEED
	
func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("sneak"):
			max_speed = SNEAK
		if event.is_action_released("sneak"):
			max_speed = SPEED
		
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
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var frontVector = get_global_transform().basis.z;
		var sideVector = get_global_transform().basis.x;

		var frontForce = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
		var sideForce = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")

		velocity = Vector3.ZERO if $HasFloor.is_colliding() else Vector3.DOWN

		if frontForce != 0:
			velocity += frontVector * _delta * frontForce * max_speed
		if sideForce != 0:
			velocity += sideVector * _delta * sideForce * max_speed
			
		if Vector3.ZERO != velocity:
			velocity = move_and_slide(velocity, Vector3.UP)
				
		if INF != camXRotation:
			$Camera.rotation_degrees.x = camXRotation
			camXRotation = INF
			
		if INF != spinForce:
			rotate_y(spinForce)
			spinForce = INF
			
		if Vector3.INF != newPos:
			var transform = get_transform()
			transform.origin = newPos
			set_transform(transform)
			newPos = Vector3.INF
		
func resetPosition(_pos : Vector3):
	newPos = _pos

func unpdateCamera():
	$Camera.current = true
	
#gameplay

const PICK_TIMER_MAX = 3
const TRAY_SIZE = Vector2(0.25, 0.2)
var table = null
var pickTimer = PICK_TIMER_MAX
var plateIndex = -1

signal pick_up
func startPickup(_table):
	emit_signal("pick_up", PICK_TIMER_MAX, pickTimer)
	table = _table
	$PickupTimer.start()
	pass
	
func cancelPickup(_table):
	if table == _table:
		table = null
		pickTimer = PICK_TIMER_MAX
		plateIndex = -1
	emit_signal("pick_up", PICK_TIMER_MAX, 0)


func _onPickupTimer():
	if null != table:
		if pickTimer == 0:
			$PlateTimer.start()
		else:
			emit_signal("pick_up", PICK_TIMER_MAX, pickTimer)
			$PickupTimer.start()
			pickTimer -= 1

func _onPlateTimer():
	if plateIndex < 0:
		emit_signal("pick_up", PICK_TIMER_MAX, pickTimer)
	if null != table and plateIndex < table.plates.size() - 1:
		plateIndex+=1
		var newPosition = $TrayIndicator.global_transform.origin
		newPosition.x += RNG.randf_range(-TRAY_SIZE.x,TRAY_SIZE.x)
		newPosition.y += 0.5
		newPosition.z += RNG.randf_range(-TRAY_SIZE.y,TRAY_SIZE.y)
		if is_instance_valid(table.plates[plateIndex]):
			table.plates[plateIndex].pos = newPosition
		$PlateTimer.start()
	else:
		cancelPickup(table)
		
		
