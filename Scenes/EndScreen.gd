extends Control

class_name EndScreen

onready var panel : Panel = $Panel
onready var label : Label = $Panel/Label
onready var tween : Tween = $Panel/Tween

var opacity = 0
var style = StyleBoxFlat.new()

func _ready():
	panel.set('custom_styles/panel', style)

func _process(_delta):
	style.set_bg_color(Color(0,0,0,opacity))
	label.set('custom_colors/font_color', Color(0,0,0,opacity))

func fade_out():
	panel.visible = true
	tween.interpolate_property(self, "opacity", 0, 255, 2, tween.TRANS_LINEAR, tween.EASE_IN)
	tween.start()
