extends MarginContainer

onready var message = get_node("VBoxContainer/Message")
onready var buttons = get_node("VBoxContainer/VSplitContainer")

func _ready():
	reset()


func reset():
	message.hide()
	buttons.hide()


func set_text_and_show(text):
	message.set_text(text)
	message.show()


func hide_text():
	message.hide()


func show_buttons():
	buttons.show()


func hide_buttons():
	buttons.hide()
