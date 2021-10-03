extends MeshInstance

var _rng : RandomNumberGenerator

var isEmpty = false
const EMPTY_CHANCE = 25

const ChairScene = preload("res://Items/Chair.tscn")
var CHAIR_TRANSFORM = [
	[Vector2(-1.3,-0.9), 0],
	[Vector2(-1.3,0.8), 0],
	[Vector2(1.2,-0.9), 180],
	[Vector2(1.2,0.9), 180],
	[Vector2(0,-2.2), -90],
	[Vector2(0,2), 90],
];
const CHAIR_VARIATION = 10
var chairs = []
var chairAmount = 0

const PlateScene = preload("res://Items/Plate.tscn")
const TABLE_RECT = Rect2(-1,-2, 2,4)
var plates = []
var plateAmount = 0

func init(RNG, _pos):
	_rng = RNG
	isEmpty = _rng.randi_range(0, 100) < EMPTY_CHANCE
	translation = _pos
	CHAIR_TRANSFORM.shuffle()
	chairAmount = _rng.randi_range(1, 6)
	plateAmount = _rng.randi_range(0, chairAmount * 2) + int(6 / chairAmount)
	for i in chairAmount:
		var chair = ChairScene.instance()
		var chairTransform = CHAIR_TRANSFORM[i]
		chair.scale = (Vector3.ONE / 2.0)
		var variation = CHAIR_VARIATION / 10.0
		var xVariation = _rng.randi_range(-variation, variation) / 10.0
		var zVariation = _rng.randi_range(-variation, variation) / 10.0
		var x = chairTransform[0].x + xVariation
		var z = chairTransform[0].y + zVariation
		chair.translation = Vector3(x, 0.1, z)
		chair.rotation_degrees.y = chairTransform[1] + _rng.randi_range(-CHAIR_VARIATION , CHAIR_VARIATION)
		chairs.append(chair)
		$Chairs.add_child(chair)
		pass
	if not isEmpty:
		for i in plateAmount:
			var plate = PlateScene.instance()
			var platePos = translation
			platePos.y += 1.5
			platePos.x += _rng.randf_range(TABLE_RECT.position.x, TABLE_RECT.end.x)
			platePos.z += _rng.randf_range(TABLE_RECT.position.y, TABLE_RECT.end.y)
			plate.init(_rng, platePos)
			plate.connect("bye", self, "_recountPlates")
			plates.append(plate)
			$Plates.add_child(plate)
			pass

func _recountPlates(plate):
	plate.disconnect("bye", self, "_recountPlates")
	$Plates.remove_child(plate)
	plates = $Plates.get_children()

const PlayerScene = preload("res://Player/Player.tscn")
signal loading_plates
func _onLoadingEnter(body):
	if PlayerScene.get_path() == body.get_filename():
		emit_signal("loading_plates", self, true)


func _onLoadingExited(body):
	if PlayerScene.get_path() == body.get_filename():
		emit_signal("loading_plates", self, false)
