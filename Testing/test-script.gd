extends Spatial

var RNG = null
const tScene = preload("res://Items/Table.tscn")
const tSize = Vector2(4, 6)
const NONE_TABLE_CHANCE = 20
const dudeSpace = 4

var sqSize = 7

func _ready():
	RNG = RandomNumberGenerator.new()
	RNG.randomize()
	for x in range(sqSize):
		for y in range(sqSize):
			if RNG.randi_range(0, 100) > NONE_TABLE_CHANCE or (x == 0 and y == 0):
				var table = tScene.instance()
				var tpos = Vector3.ZERO
				tpos.y = 0.475
				tpos.x = dudeSpace + (x * (tSize.x + dudeSpace)) - (sqSize/2.0 * (tSize.x + dudeSpace))
				tpos.z = dudeSpace + (y * (tSize.y + dudeSpace)) - (sqSize/2.0 * (tSize.y + dudeSpace))
				table.init(RNG, tpos)
				add_child(table)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
