extends Node

enum {HOWTO, SMALL, NORMAL, BIG}
var RNG : RandomNumberGenerator = RandomNumberGenerator.new()
export (String) var SEED : String = "LD49"

const LevelScene = preload("res://Level/Level.tscn")
const PlayerScene = preload("res://Player/Player.tscn")
var level = null
var levelSelected = BIG
var player = null

	

func playerPlatePickup(table, isStart : bool):
	if isStart and table.plates.size():
		player.startPickup(table)
	else:
		player.cancelPickup(table)

#TODO make pause menu
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		level.stopMusic()
		$GUI.show()

func __resetPlayerCamera(_val):
	if !_val and null != player:
		player.unpdateCamera()

func __parseSeed():
	var byteArray = SEED.to_ascii()
	var _seed = 1
	for b in byteArray:
		_seed *= b
	RNG.seed = _seed


func _onPlayPress(_seed, _level):
	SEED = _seed
	levelSelected = _level
	__parseSeed()
	if null != level:
		remove_child(level)
		level.queue_free()
		level = null
	level = LevelScene.instance()
	level.connect("camera_change", self, "__resetPlayerCamera")
	level.connect("update_HUD", self, "__updateHud")
	level.connect("end", self, "__showEndScreen")
	add_child(level)
	level.init(RNG, levelSelected)
	
	if null == player:
		player = PlayerScene.instance()
		add_child(player)
		player.connect("pick_up", self, "__showPickup")
	player.init(RNG)
	player.rotation.y += 180
	player.resetPosition(level.startRoomCoords + Vector3(4,1,4))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$HUD/CenterContainer/HBoxContainer/Seed/Value.text = SEED
	var mapText = "TINY"
	match(levelSelected):
		HOWTO: 
			mapText = "TINY"
		SMALL: 
			mapText = "SMALL"
		NORMAL: 
			mapText = "NORMAL"
		BIG: 
			mapText = "LARGE"
	$HUD/CenterContainer/HBoxContainer/Map/Value.text = mapText
	$GUI.hide()
	
func __showPickup(maxV, curV):
	if curV == 0:
		$HUD/Loading.hide()
	else:
		$HUD/Loading/VBoxContainer/Bar.max_value = maxV
		$HUD/Loading/VBoxContainer/Bar.value = maxV - curV
		$HUD/Loading.show()
	
func __updateHud(plates, done, borked):
	$HUD/CenterContainer/HBoxContainer/Destroyed/Value.text = str(borked)
	$HUD/CenterContainer/HBoxContainer/Done/Value.text = str(done)
	$HUD/CenterContainer/HBoxContainer/Left/Value.text = str(plates)
	
func __showEndScreen():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$HUD/WIN.show()
	$HUD/WIN/AcceptDialog.popup()


func _on_AcceptDialog_confirmed():
	$HUD/WIN.hide()
	level.stopMusic()
	$GUI.show()
