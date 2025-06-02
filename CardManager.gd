extends Node2D

var player_hand_reference

func _ready() -> void:
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)

#return what ever -> cursor click
func raycast_check_for_card():
	var space_state = get_world_2d() .direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null


func on_left_click_released():
	print("card manager left mouse released signal")
