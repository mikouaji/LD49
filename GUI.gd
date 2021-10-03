extends Control


func _ready():
	var opt = $CenterContainer/VBoxContainer/Level/OptionButton
	opt.add_item("TINY",0)
	opt.add_item("SMALL",1)
	opt.add_item("NORMAL",2)
	opt.add_item("LARGE",3)
	opt.selected = 1
	pass


func _on_Quit_pressed():
	get_tree().quit()


func _on_Controls_pressed():
	$Controls.visible = true
	$Controls/Keys.popup()


func _on_AcceptDialog_confirmed():
	$Controls/Gameplay.popup()


func _on_Gameplay_confirmed():
	$Controls.visible = false

signal play
func _on_Play_pressed():
	var _seed = $CenterContainer/VBoxContainer/Seed/Label.text
	var _map = $CenterContainer/VBoxContainer/Level/OptionButton.selected
	emit_signal("play", _seed, _map)
