extends Control

var life1TexFrame
var life2TexFrame
var life3TexFrame
var life4TexFrame
var life5TexFrame
var energyBar
var ultimateBar


func _ready():
	life1TexFrame = get_node("HBoxContainer/MarginContainer/VBoxContainer/LifePrototype/MarginContainer/LifeBG/LifeSlot/Life1")
	life2TexFrame = get_node("HBoxContainer/MarginContainer/VBoxContainer/LifePrototype/MarginContainer/LifeBG/LifeSlot/Life2")
	life3TexFrame = get_node("HBoxContainer/MarginContainer/VBoxContainer/LifePrototype/MarginContainer/LifeBG/LifeSlot/Life3")
	life4TexFrame = get_node("HBoxContainer/MarginContainer/VBoxContainer/LifePrototype/MarginContainer/LifeBG/LifeSlot/Life4")
	life5TexFrame = get_node("HBoxContainer/MarginContainer/VBoxContainer/LifePrototype/MarginContainer/LifeBG/LifeSlot/Life5")
	energyBar = get_node("HBoxContainer/MarginContainer/VBoxContainer/EnergyPrototype/Status/Energy")
	ultimateBar = get_node("HBoxContainer/MarginContainer/VBoxContainer/EnergyPrototype/Status/Ultimate")


func reset():
	set_pos(Vector2(379, 380))
	life1TexFrame.show()
	life2TexFrame.show()
	life3TexFrame.show()
	life4TexFrame.show()
	life5TexFrame.show()
	energyBar.set_value(100.0)
	ultimateBar.set_value(0.0)


func update_life(life):
	if life == 5:
		life1TexFrame.show()
		life2TexFrame.show()
		life3TexFrame.show()
		life4TexFrame.show()
		life5TexFrame.show()
	elif life == 4:
		life1TexFrame.show()
		life2TexFrame.show()
		life3TexFrame.show()
		life4TexFrame.show()
		life5TexFrame.hide()
	elif life == 3:
		life1TexFrame.show()
		life2TexFrame.show()
		life3TexFrame.show()
		life4TexFrame.hide()
		life5TexFrame.hide()
	elif life == 2:
		life1TexFrame.show()
		life2TexFrame.show()
		life3TexFrame.hide()
		life4TexFrame.hide()
		life5TexFrame.hide()
	elif life == 1:
		life1TexFrame.show()
		life2TexFrame.hide()
		life3TexFrame.hide()
		life4TexFrame.hide()
		life5TexFrame.hide()
	elif life == 0:
		life1TexFrame.hide()
		life2TexFrame.hide()
		life3TexFrame.hide()
		life4TexFrame.hide()
		life5TexFrame.hide()


func update_energy(ep):
	energyBar.set_value(ep)


func update_ultimate(ulty):
	ultimateBar.set_value(ulty)
