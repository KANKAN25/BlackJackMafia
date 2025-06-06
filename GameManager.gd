extends Node

const CardDatabase = preload("res://CardDatabase.gd")
const CARD_BACK_TEXTURE = preload("res://assets/Cards/Backside_Card.png")
const SkillsScene = preload("res://Skills.tscn")

var player_hand: Array = []
var dealer_hand: Array = []
var selected_skill: String = ""
var deck: Node
var button_click_player: AudioStreamPlayer
var win_sound_player: AudioStreamPlayer
var lose_sound_player: AudioStreamPlayer
var bg_music_player: AudioStreamPlayer

var is_player_turn: bool = true
var is_player_busted: bool = false
var level

var guardian_angel_active: bool = false
var blackjack_boost_active: bool = false
var triple_draw_cards: Array = []
var is_triple_draw_active: bool = false
var guardian_angel_used: bool = false 

func _ready():
	print("✅ GameManager ready!")
	deck = get_node("../Deck")
	get_node("../Turns/ResultDisplay").visible = false
	# Setup audio players
	button_click_player = AudioStreamPlayer.new()
	button_click_player.stream = load("res://assets/music/button_click.mp3")
	add_child(button_click_player)
	
	win_sound_player = AudioStreamPlayer.new()
	win_sound_player.stream = load("res://assets/music/winsound.mp3")
	add_child(win_sound_player)
	
	lose_sound_player = AudioStreamPlayer.new()
	lose_sound_player.stream = load("res://assets/music/losesound.mp3")
	add_child(lose_sound_player)
	
	bg_music_player = AudioStreamPlayer.new()
	bg_music_player.stream = load("res://assets/music/noir.mp3")
	bg_music_player.volume_db = -20
	add_child(bg_music_player)
	bg_music_player.play()
	
	reset_game()

func show_skills_selection():
	is_player_turn = false
	var skills_instance = SkillsScene.instantiate()
	add_child(skills_instance)
	# Connect to skill selection signal
	skills_instance.connect("skill_selected", _on_skill_selected)

func _on_skill_selected(skill_name: String):
	selected_skill = skill_name
	print("Selected skill: ", skill_name)
	button_click_player.play()
	for child in get_children():
		if child.name == "SkillsManager":
			child.queue_free()
	is_player_turn = true

# Peek - See one of the dealer's hidden cards
func use_peek() -> void:
	if dealer_hand.size() >= 2:
		# Show the second card (index 1) which is usually hidden
		var card = dealer_hand[1]
		var card_name = card.card_id
		var card_image_path = "res://assets/Cards/" + card_name + ".png"
		card.get_node("CardImage").texture = load(card_image_path)
		print("👁️ Peeked at dealer's hidden card: ", card_name)

# Swap - Swap last drawn card with a random card from top 3
func use_swap() -> void:
	if player_hand.size() > 0:
		var last_card_index = player_hand.size() - 1
		var last_card_node = player_hand[last_card_index] 
		
		var top_cards = deck.peek_top_cards(3)
		if top_cards.size() > 0:
			var random_card_data = top_cards[randi() % top_cards.size()] # Get card data
	
			last_card_node.queue_free()
			player_hand.pop_back()
			
			# Draw the new card using the deck
			var new_card_node = deck.draw_card()
			if new_card_node:
				# Set the card data for the new node
				new_card_node.card_id = random_card_data.card_id
				var card_image_path = "res://assets/Cards/" + new_card_node.card_id + ".png"
				new_card_node.get_node("CardImage").texture = load(card_image_path)
				
				# Add the new card node to the player's hand array
				player_hand.append(new_card_node)
				print("🔄 Swapped last card with: ", new_card_node.card_id)
				
				# Add the new card node to the PlayerHand scene node
				var player_hand_node = get_node("../PlayerHand")
				if player_hand_node:
					player_hand_node.add_child(new_card_node)
					# Update positions
					player_hand_node.update_hand_positions(player_hand, player_hand_node.PLAYER_HAND_Y)
					
				test_hand() # Recalculate hand value and check for bust

# Blackjack Boost - If hand is 20, count as 21
func use_blackjack_boost() -> void:
	var hand_value = calculate_hand_value(player_hand)
	if hand_value == 20:
		print("💪 Blackjack Boost activated! 20 counts as 21!")
		blackjack_boost_active = true

# X-Ray - See next card in deck
func use_xray() -> void:
	var next_card = deck.peek_next_card()
	if next_card:
		print("🔍 Next card will be: ", next_card.card_id)
		# Show the card temporarily
		var card_image_path = "res://assets/Cards/" + next_card.card_id + ".png"
		var card_texture = load(card_image_path)
		
		# Create a temporary card display
		var temp_card = Sprite2D.new()
		temp_card.texture = card_texture
		temp_card.position = Vector2(960, 540)  # Center of screen
		temp_card.scale = Vector2(0.5, 0.5)  # Adjust size as needed
		add_child(temp_card)
		
		# Create a tween to fade out and remove the card
		var tween = create_tween()
		tween.tween_property(temp_card, "modulate:a", 0.0, 1.0)  # Fade out over 1 second
		tween.tween_callback(temp_card.queue_free)  # Remove the card after fade

# Guardian Angel - Prevent bust
func use_guardian_angel() -> void:
	print("👼 Guardian Angel activated! You will have a second chance!")
	guardian_angel_active = true

# Nullify - Cancel one boss passive effect
func use_nullify() -> void:
	print("❌ Nullify activated! Boss passive effect cancelled!")
	# This will be implemented when boss mechanics are added which is never

func animate_card_to_position(card: Node2D, target_position: Vector2, duration: float = 0.5) -> void:
	var tween = create_tween()
	tween.tween_property(card, "position", target_position, duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

# Triple Draw - Draw 3 cards and let player choose one
func use_triple_draw() -> void:
	triple_draw_cards = []
	is_triple_draw_active = true
	
	# Draw 3 cards
	for i in range(3):
		var card = deck.draw_card()
		if card:
			triple_draw_cards.append(card)
			var target_position = Vector2(800 + (i * 200), 500) 
			animate_card_to_position(card, target_position)
			card.get_node("Area2D").input_pickable = true
			# Connect the card's input signal
			card.get_node("Area2D").connect("input_event", _on_triple_draw_card_clicked.bind(card))
	
	if triple_draw_cards.size() > 0:
		print("🎴 Triple Draw: Choose one card to keep")

func _on_triple_draw_card_clicked(_viewport, event, _shape_idx, card):
	if is_triple_draw_active and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Add the chosen card to player's hand
		player_hand.append(card)
		print("🎴 Triple Draw: Kept card: ", card.card_id)
		
		# Update the position of the chosen card to match player's hand
		var player_hand_node = get_node("../PlayerHand")
		if player_hand_node:
			player_hand_node.update_hand_positions(player_hand, player_hand_node.PLAYER_HAND_Y)
		
		await get_tree().create_timer(0.5).timeout
		
		# Hide the other cards instead of deleting them (cause its buggy if we free em)
		for other_card in triple_draw_cards:
			if other_card != card:
				other_card.visible = false
				other_card.get_node("Area2D").input_pickable = false
		
		# Reset triple draw state
		triple_draw_cards.clear()
		is_triple_draw_active = false
		
		# Test the hand with the new card
		test_hand()

func _on_skills_button_pressed():
	if is_player_turn and not is_player_busted and selected_skill != "":
		print("🎮 Activating skill: ", selected_skill)
		match selected_skill:
			"Peek_Icon":
				use_peek()
			"Swap_Icon":
				use_swap()
			"Blackjack_Boost_Icon":
				use_blackjack_boost()
			"X_Ray_Icon":
				use_xray()
			"Guardian_Angel_Icon":
				use_guardian_angel()
			#"Nullify_Icon":
				#use_nullify()
			"Triple_Draw_Icon":
				use_triple_draw()
		selected_skill = ""  # Reset selected skill after use
	else:
		print("⚠️ Cannot use skill: ", 
			"Not player's turn" if not is_player_turn else 
			"Player busted" if is_player_busted else 
			"No skill selected")

func reset_game():
	level = 1
	initialize_round()
	
func initialize_round():
	var level_manager = get_node("../LevelManager")
	level_manager.initialize_level(level)
	# Remove card nodes from previous round
	var player_hand_node = get_node("../PlayerHand") 
	player_hand_node.clear()
	player_hand.clear()
	dealer_hand.clear()
	deck = get_node("../Deck")
	deck.reset_deck()
	is_player_turn = true
	is_player_busted = false
	guardian_angel_active = false
	blackjack_boost_active = false
	print("🔁 Game reset. Player's turn starts.")
	get_node("../Turns/PlayersTurn").visible = true
	get_node("../Turns/DealersTurn").visible = false
	get_node("../Turns/Tie").visible = false
	# Deal 2 cards to player
	for i in range(2):
		var card = deck.draw_card()
		if card:
			add_card_to_hand(card)
	# Deal 2 cards to dealer
	for i in range(2):
		var hide_card = false
		if i == 1:
			hide_card = true
		var card = deck.draw_card(true, hide_card)
		if card:
			add_card_to_dealer(card)
	# Show skills
	if (level == 1 or level == 4 or level == 7) and not guardian_angel_used:
		show_skills_selection()

func calculate_hand_value(hand: Array, dealer = false) -> int:
	var total = 0
	var ace_count = 0

	for card in hand:
		var card_name = card.card_id

		if not CardDatabase.CARDS.has(card_name):
			print("⚠️ Warning: Card name not found in database: ", card_name)
			continue

		var card_data = CardDatabase.CARDS[card_name]
		var value = card_data.get("value", 0)
		total += value

		# Track Aces (they always start as 1)
		if value == 11:
			ace_count += 1

	# Now try upgrading Aces from 1 to 11, one by one if it helps
	while ace_count > 0 and total > 21:
		total -= 10
		ace_count -= 1

	# Apply Blackjack Boost if active
	if blackjack_boost_active and total == 20 and not dealer:
		total = 21

	return total

func test_hand():
	var hand_total = calculate_hand_value(player_hand)
	print("🧮 Player hand total: ", hand_total)

	if hand_total > 21:
		if guardian_angel_active:
			print("👼 Guardian Angel prevents bust!")
			guardian_angel_active = false
			guardian_angel_used = true
			initialize_round()
		else:
			print("💥 Bust! Player can't draw more.")
			is_player_busted = true
			is_player_turn = false
			dealer_turn()
	elif hand_total == 21:
		print("🎉 Blackjack! Turn ends.")
		is_player_turn = false
		dealer_turn()
	else:
		print("🃏 Player can continue drawing.")

func add_card_to_hand(card: Node):
	player_hand.append(card)
	test_hand()

func add_card_to_dealer(card: Node):
	dealer_hand.append(card)

func _on_HitButton_pressed():
	if is_player_turn and not is_player_busted:
		var new_card = deck.draw_card()
		if new_card:
			add_card_to_hand(new_card)

func _on_StandButton_pressed():
	if is_player_turn:
		print("Stand button pressed")
		is_player_turn = false
		dealer_turn()

func dealer_turn():
	print("🂠 Dealer's turn starts.")
	get_node("../Turns/PlayersTurn").visible = false
	get_node("../Turns/DealersTurn").visible = true
	# Reveal dealer's hidden card first (show all dealer cards face up)
	for card_node in dealer_hand:
		var card_name = card_node.card_id
		var card_image_path = "res://assets/Cards/" + card_name + ".png"
		card_node.get_node("CardImage").texture = load(card_image_path)
		deck.card_sound_player.play()  # Play sound when card is revealed
		await get_tree().create_timer(0.5).timeout
	deck = get_node("../Deck")


	# Dealer draws cards while total less than 17
	if not is_player_busted:
		while calculate_hand_value(dealer_hand, true) < 17:
			await get_tree().create_timer(0.7).timeout 
			var new_card = deck.draw_card(true,false)
			if new_card:
				add_card_to_dealer(new_card)
			else:
				print("Deck empty - dealer can't draw more.")
				break
	decide_winner()

func decide_winner():
	var player_total = calculate_hand_value(player_hand)
	var dealer_total = calculate_hand_value(dealer_hand, true)
	var level_manager = get_node("../LevelManager")
	var player_win 
	var tie = false
	guardian_angel_used = false
	print("📊 Final Results — Player: ", player_total, " | Dealer: ", dealer_total)
	await get_tree().create_timer(0.7).timeout
	if player_total > 21:
		print("❌ Player busts. Dealer wins.")
		player_win = false
		lose_sound_player.play()
	elif dealer_total > 21:
		print("❌ Dealer busts. Player wins!")
		player_win = true
		level += 1
		win_sound_player.play()
	elif player_total > dealer_total:
		print("✅ Player wins!")
		player_win = true
		level += 1
		win_sound_player.play()
	elif dealer_total > player_total:
		print("🏆 Dealer wins!")
		player_win = false
		lose_sound_player.play()
	else:
		print("🤝 It's a tie!")
		player_win = false
		tie = true
	if tie == true:
		get_node("../Turns/Tie").visible = true
		await get_tree().create_timer(0.7).timeout
		initialize_round()
	if (level > 9 or player_win == false) and not tie:
		level_manager.end_game(player_win, tie)
	else:
		initialize_round()
	# Optionally reset game or wait for player input
	# reset_game()
