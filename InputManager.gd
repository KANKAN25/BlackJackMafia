extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD =1
const COLLISION_MASK_DECK =5

var card_manager_reference
var deck_reference 
var game_manager_reference

func _ready() -> void:
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"
	game_manager_reference = $"../GameManager"


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_LEFT:
		if event.pressed:
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")


func raycast_at_cursor():
	var space_state = get_world_2d() .direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result = space_state.intersect_point(parameters)
	#if result.size() > 0:
		#var result_collision_mask = result[0].collider.collision_mask
		#if result_collision_mask == COLLISION_MASK_CARD:
			#card clicked
			#var card_found = result[0].collider.get_parent()
			#if card_found:
			#	card_manager_reference.start_drag(card_found)
		#elif result_collision_mask == COLLISION_MASK_DECK:
		#	game_manager_reference.on_deck_clicked()


func _on_hit_pressed() -> void:
	game_manager_reference._on_HitButton_pressed() 
	
func _on_stand_pressed() -> void:
	game_manager_reference._on_StandButton_pressed()

func _on_hit_mouse_entered() -> void:
	$"../Hit".modulate = Color(1.5, 1.5, 1.5) 

func _on_stand_mouse_entered() -> void:
	$"../Stand".modulate = Color(1.5, 1.5, 1.5)

func _on_hit_mouse_exited() -> void:
	$"../Hit".modulate = Color(1, 1, 1)

func _on_stand_mouse_exited() -> void:
	$"../Stand".modulate = Color(1, 1, 1)

func _on_skills_btn_mouse_entered() -> void:
	$"../SkillsBtn".modulate = Color(1.5, 1.5, 1.5)

func _on_skills_btn_mouse_exited() -> void:
	$"../SkillsBtn".modulate = Color(1, 1, 1)

func _on_skills_btn_pressed():
	game_manager_reference._on_skills_button_pressed()
	
func _on_play_again_mouse_entered() -> void:
	$"../Turns/ResultDisplay/PlayAgain".modulate = Color(0.7, 0.7, 0.7)

func _on_play_again_mouse_exited() -> void:
	$"../Turns/ResultDisplay/PlayAgain".modulate = Color(1, 1, 1)

func _on_play_again_pressed() -> void:
	game_manager_reference.reset_game()
	get_node("../Turns/ResultDisplay").visible = false
