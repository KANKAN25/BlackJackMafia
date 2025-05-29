extends Control

@onready var play_button = $BG/Play_Button
var intro_cutscene_scene = preload("res://intro_cutscene.tscn")  # update with actual path
var intro_cutscene_instance : Node2D

func _ready():
	play_button.pressed.connect(on_play_pressed)

func on_play_pressed():
	if intro_cutscene_instance == null:
		intro_cutscene_instance = intro_cutscene_scene.instantiate()
		get_tree().root.add_child(intro_cutscene_instance)
		intro_cutscene_instance.animation_player.play()
