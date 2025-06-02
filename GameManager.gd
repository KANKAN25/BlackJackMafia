extends Node

const CardDatabase = preload("res://CardDatabase.gd")
const CARD_BACK_TEXTURE = preload("res://assets/Cards/Backside_Card.png")  # define the back texture here

var player_hand: Array = []
var dealer_hand: Array = []

var is_player_turn: bool = true
var is_player_busted: bool = false
var level

func _ready():
	print("✅ GameManager ready!")
	reset_game()

func reset_game():
	level = 1
	initialize_round()
	
func initialize_round():
	var level_manager = get_node("../LevelManager")
	level_manager.initialize_level(level)
	# Remove card nodes from previous round
	var player_hand_node = get_node("../PlayerHand")  # or whatever node this script is attached to
	player_hand_node.clear()
		
	player_hand.clear()
	dealer_hand.clear()
	is_player_turn = true
	is_player_busted = false
	print("🔁 Game reset. Player's turn starts.")

	var deck = get_node("../Deck")
	deck.reset_deck()
	
	# Deal 2 cards to player
	for i in range(2):
		var card = deck.draw_card()
		if card:
			add_card_to_hand(card)
	
	# Deal 2 cards to dealer
	for i in range(2):
		var hide = false
		if i == 1:
			hide = true
		var card = deck.draw_card(true,hide)
		if card:
			add_card_to_dealer(card)
	

func calculate_hand_value(hand: Array) -> int:
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

	return total

func test_hand():
	var hand_total = calculate_hand_value(player_hand)
	print("🧮 Player hand total: ", hand_total)

	if hand_total > 21:
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
		var deck = get_node("../Deck")
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
	# Reveal dealer's hidden card first (show all dealer cards face up)
	for card_node in dealer_hand:
		var card_name = card_node.card_id
		var card_image_path = "res://assets/Cards/" + card_name + ".png"
		card_node.get_node("CardImage").texture = load(card_image_path)
		await get_tree().create_timer(0.5).timeout
	var deck = get_node("../Deck")

	# Dealer draws cards while total less than 17
	if not is_player_busted:
		await get_tree().create_timer(0.7).timeout  # small delay for each card reveal
		while calculate_hand_value(dealer_hand) < 17:
			var new_card = deck.draw_card(true,false)
			if new_card:
				add_card_to_dealer(new_card)
			else:
				print("Deck empty - dealer can't draw more.")
				break
	await get_tree().create_timer(0.7).timeout
	decide_winner()

func decide_winner():
	var player_total = calculate_hand_value(player_hand)
	var dealer_total = calculate_hand_value(dealer_hand)
	var level_manager = get_node("../LevelManager")
	var player_win 
	var tie = false
	print("📊 Final Results — Player: ", player_total, " | Dealer: ", dealer_total)

	if player_total > 21:
		print("❌ Player busts. Dealer wins.")
		player_win = false
	elif dealer_total > 21:
		print("❌ Dealer busts. Player wins!")
		player_win = true
		level += 1
	elif player_total > dealer_total:
		print("✅ Player wins!")
		player_win = true
		level += 1
	elif dealer_total > player_total:
		print("🏆 Dealer wins!")
		player_win = false
	else:
		print("🤝 It's a tie!")
		player_win = false
		tie = true
	if tie == true:
		initialize_round()
	if (level > 9 or player_win == false) and not tie:
		level_manager.end_game(player_win, tie)
	else:
		initialize_round()
	# Optionally reset game or wait for player input
	# reset_game()
