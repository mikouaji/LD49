extends Spatial

const CornerRoomScene = preload("res://Level/GridRooms/Corner.tscn")
const WallRoomScene = preload("res://Level/GridRooms/Wall.tscn")
const FloorRoomScene = preload("res://Level/GridRooms/NoWall.tscn")
const StartRoomScene = preload("res://Level/GridRooms/Room.tscn")
const TableScene = preload("res://Items/Table.tscn")

const ROOM_SIZE = 10.0
const ROOM_TABLE_PLACEMENT_FIX = Vector2(0.5, 0.4)
const TABLE_SIZE = Vector2(4, 6)
const NONE_TABLE_CHANCE = 20
const PLAYER_SPACE = 4

const SETTINGS = [
	{
		"size": Vector2(3,2),
	},
	{
		"size": Vector2(3,3),
	},
	{
		"size": Vector2(4,6),
	},
	{
		"size": Vector2(7,10),
	},
]

var RNG : RandomNumberGenerator
var type : int = -1

var startRoomCoords = Vector3.INF
var rooms = []
var tables = []

var plates = 0
var platesDone = 0
var platesBorked = 0

signal camera_change
func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("map"):
			emit_signal("camera_change", true)
			$TopCam.current = true
		if event.is_action_released("map"):
			emit_signal("camera_change", false)
			$TopCam.current = false

func init(_rng: RandomNumberGenerator, _type : int):
	RNG = _rng
	type = _type
	emit_signal("camera_change", false)
	$TopCam.current = false
	_build()
	_placeTables()
	$AudioStreamPlayer.play()
	_updateHUD()
	
func stopMusic():
	$AudioStreamPlayer.stop()
	
func _placeTables():
	var xMax = SETTINGS[type].size.x
	var yMax = SETTINGS[type].size.y
	for x in range(xMax):
		for y in range(yMax):
			if RNG.randi_range(0, 100) > NONE_TABLE_CHANCE or (x == 0 and y == 0):
				var table = TableScene.instance()
				var tpos = Vector3.ZERO
				tpos.y = 0.475
				tpos.x = PLAYER_SPACE + (x * (TABLE_SIZE.x + PLAYER_SPACE)) - (xMax/2.0 * (TABLE_SIZE.x + PLAYER_SPACE))
				tpos.z = PLAYER_SPACE + (y * (TABLE_SIZE.y + PLAYER_SPACE)) - (yMax/2.0 * (TABLE_SIZE.y + PLAYER_SPACE))
				table.init(RNG, tpos)
				tables.append(table)
				$Tables.add_child(table)
				table.connect("loading_plates", get_parent(), "playerPlatePickup")
				plates += table.plates.size()
	
func _build():
	var xMax = SETTINGS[type].size.x
	var yMax = SETTINGS[type].size.y
	for x in range(xMax):
		for y in range(yMax):
			var tile = FloorRoomScene.instance()
			#floor for start room
			if not (x == floor(xMax / 2.0) and y == yMax -1):
				##walls
				if x == 0 or x == xMax -1 or y == 0 or y == yMax -1:
					tile = WallRoomScene.instance()
					if x == xMax -1:
						tile.rotation_degrees.y +=180
					elif y == yMax -1:
						tile.rotation_degrees.y +=90
					elif y == 0:
						tile.rotation_degrees.y -=90
				##corners
				if (x == 0 or x == xMax -1) and (y == 0 or y == yMax -1):
					tile = CornerRoomScene.instance()
					if x == xMax -1:
						tile.rotation_degrees.y +=180
						if y == yMax -1:
							tile.rotation_degrees.y -=90
					else:
						if y == 0:
							tile.rotation_degrees.y -=90
			tile.translation = Vector3(
				(- (xMax/2.0) + x + ROOM_TABLE_PLACEMENT_FIX.x) * ROOM_SIZE,
				0,
				(- (yMax/2.0) + y + ROOM_TABLE_PLACEMENT_FIX.y) * ROOM_SIZE
			)
			rooms.append(tile)
			$Tiles.add_child(tile)
	var startRoom = StartRoomScene.instance()
	startRoomCoords = Vector3(
		(- (xMax/2.0) + floor(xMax/2.0) + ROOM_TABLE_PLACEMENT_FIX.x) * ROOM_SIZE, 
		0, 
		(- (yMax/2.0)  + yMax + ROOM_TABLE_PLACEMENT_FIX.y) * ROOM_SIZE
	)
	startRoom.translation = startRoomCoords
	startRoom.rotation_degrees.y +=90
	startRoom.get_node("Washer").connect("plate_delivery", self, "_onPlateDone")
	rooms.append(startRoom)
	$Tiles.add_child(startRoom)
	pass

signal update_HUD
func _updateHUD():
	emit_signal("update_HUD", plates, platesDone, platesBorked)

const PlateScene = preload("res://Items/Plate.tscn")
func _onPlateBreakEnter(body):
	if body.get_filename() == PlateScene.get_path():
		body.bork()
		platesBorked += 1
		plates -=1
		__checkEndLevel()
		
func _onPlateDone():
	platesDone +=1
	plates -=1
	__checkEndLevel()

signal end
func __checkEndLevel():
	_updateHUD()
	if 0 == plates:
		emit_signal("end")
