extends RigidBody

enum {FLAT, SMALL, DEEP}

var TYPES = []
var type = -1
var pos = Vector3.INF

var RNG : RandomNumberGenerator

signal bye

func bork(quiet : bool = false):
	$BreakSound.pitch_scale = RNG.randf_range(TYPES[type].pitch.x, TYPES[type].pitch.y)
	if quiet:
		_on_BreakSound_finished()
	else:
		$BreakSound.play()
		$Particles.restart()

func init(_rng : RandomNumberGenerator, _pos):
	RNG = _rng
	pos = _pos
	TYPES = [
		{
			'mesh':	$FlatMesh,
			'collision': $FlatCollision,
			"pitch": Vector2(0.8, 1.2)
		},
		{
			'mesh':	$SmallMesh,
			'collision': $SmallCollision,
			"pitch": Vector2(0.9, 1.4)
		},
		{
			'mesh':	$DeepMesh,
			'collision': $DeepCollision,
			"pitch": Vector2(0.75, 1.1)
		},
	]
	type = _rng.randi_range(0, TYPES.size() - 1)
	for i in range(TYPES.size()):
		if type == i:
			TYPES[i].mesh.show()
			TYPES[i].collision.show()
		else:
			remove_child(TYPES[i].mesh)
			remove_child(TYPES[i].collision)
	pass

func _integrate_forces(state):
	if Vector3.INF != pos:
		var transform = state.get_transform()
		transform.origin = pos
		state.set_transform(transform)
		pos = Vector3.INF


func _on_BreakSound_finished():
	emit_signal("bye", self)
	queue_free()
