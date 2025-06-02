extends Node2D

const SKILL_SCENE_PATH = "res://Scenes/Skill.tscn"

var all_skills = [
	"Guardian_Angel_Icon",
	"X_Ray_Icon",
	"Triple_Draw_Icon",
	"Peek_Icon",
	"Swap_Icon",
	"Blackjack_Boost_Icon",
	"Nullify_Icon"
]

var skill_descriptions = {
	"Guardian_Angel_Icon": "Guardian_Angel_Desc",
	"X_Ray_Icon": "X_Ray_Desc",
	"Triple_Draw_Icon": "Triple_Draw_Desc",
	"Peek_Icon": "Peek_Desc",
	"Swap_Icon": "Swap_Desc",
	"Blackjack_Boost_Icon": "BJ_Boost_Desc",
	"Nullify_Icon": "Nullify_Desc"
}

var current_skills = []
var description_sprite

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("click")

func _ready() -> void:
	randomize()  # Initialize the random number generator
	description_sprite = $"SkillDescription/Description"
	show_skills()
	# Set default description to first skill
	if current_skills.size() > 0:
		update_description(current_skills[0])

func show_skills() -> void:
	# Randomly select three different skills
	var available_skills = all_skills.duplicate()
	current_skills = []
	
	for i in range(3):
		if available_skills.size() > 0:
			var random_index = randi() % available_skills.size()
			current_skills.append(available_skills[random_index])
			available_skills.remove_at(random_index)
	
	# Create and show selected skills
	var skill_scene = preload(SKILL_SCENE_PATH)
	
	# Add skill to first slot
	var skill1 = skill_scene.instantiate()
	skill1.name = "Skill1"
	$"window/Skill".add_child(skill1)
	var skill1_icon_path = "res://assets/Skills/" + current_skills[0] + ".png"
	skill1.get_node("Icon").texture = load(skill1_icon_path)
	skill1.get_node("Icon/Area2D").connect("mouse_entered", _on_skill_hover.bind(0))
	skill1.get_node("Icon/Area2D").connect("mouse_exited", _on_skill_exit.bind(0))
	
	# Add skill to second slot
	var skill2 = skill_scene.instantiate()
	skill2.name = "Skill2"
	$"window/Skill2".add_child(skill2)
	var skill2_icon_path = "res://assets/Skills/" + current_skills[1] + ".png"
	skill2.get_node("Icon").texture = load(skill2_icon_path)
	skill2.get_node("Icon/Area2D").connect("mouse_entered", _on_skill_hover.bind(1))
	skill2.get_node("Icon/Area2D").connect("mouse_exited", _on_skill_exit.bind(1))
	
	# Add skill to third slot
	var skill3 = skill_scene.instantiate()
	skill3.name = "Skill3"
	$"window/Skill3".add_child(skill3)
	var skill3_icon_path = "res://assets/Skills/" + current_skills[2] + ".png"
	skill3.get_node("Icon").texture = load(skill3_icon_path)
	skill3.get_node("Icon/Area2D").connect("mouse_entered", _on_skill_hover.bind(2))
	skill3.get_node("Icon/Area2D").connect("mouse_exited", _on_skill_exit.bind(2))

func _on_skill_hover(skill_index: int) -> void:
	update_description(current_skills[skill_index])

func _on_skill_exit(_skill_index: int) -> void:
	# When mouse exits, show the first skill's description
	update_description(current_skills[0])

func update_description(skill_name: String) -> void:
	var desc_path = "res://assets/Skills/description/" + skill_descriptions[skill_name] + ".png"
	description_sprite.texture = load(desc_path)
