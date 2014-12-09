require 'pry'
player_bank_account = [100]
total_cards_played = 0

def valid_decision?(the_decision)
  if ['y', 'n'].include?(the_decision.downcase)
    true
  else
    print_string "You must enter Y or N. Please try again"
  end
end

def valid_value?(the_bet_value, bank_account)
  if the_bet_value =~ /\D/
    print_string "You must enter a valid number"
  elsif the_bet_value.to_i == 0
    print_string "You must enter a value higher than zero"
  elsif (bank_account[0] - the_bet_value.to_i) < 0 
    print_string "You do not have enough funds for that bet. Please enter a new bet"
  else
    true
  end
end

def print_string(text)
  puts "\n==> #{text}"
end

def deck_of_cards
  {hearts: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], diamonds: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], 
    spades: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], clubs: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King']}
end

#deals a random card from the game_deck.  That card is then removed from the game_deck array, stored as a hash and returned.
def deal_a_card(from_the_deck)
  #delete any empty hashes from the deck array otherwise there will be an error because it will be picking a nil result
  if from_the_deck.include?({})
    from_the_deck.delete({})
  end
  
  deck_chosen_from = from_the_deck.sample
  key_chosen_from_deck = deck_chosen_from.keys.sample
  value_chosen_from_deck = deck_chosen_from[key_chosen_from_deck].sample
  
  remove_from_deck(deck_chosen_from, key_chosen_from_deck, value_chosen_from_deck)

  #delete any hash key with an empty array value otherwise there will be an error because it will be picking a nil result
  if deck_chosen_from[key_chosen_from_deck].empty?
    deck_chosen_from.delete(key_chosen_from_deck)
  end

  picked_card = [key_chosen_from_deck, value_chosen_from_deck]
end

def remove_from_deck(which_deck, key, value)
  which_deck[key].delete(value)
end

def display_cards_on_table(player_card_array, dealer_card_array, player_name)
  print_string "The dealers cards are:"
  dealer_card_array.each { |card_array| puts "#{card_array[1]} of #{card_array[0]}"}
  
  print_string "#{player_name}'s cards are:"
  player_card_array.each { |card_array| puts "#{card_array[1]} of #{card_array[0]}"}
end

#returns a value with the hand total in it. 
def card_total(player_or_dealer_array)
  value_array = player_or_dealer_array.map { |v| v[1] }
  card_value_counter = 0
  
  value_array.each do |value|
    if value.is_a? Integer
      card_value_counter += value
    elsif value != 'Ace'
      card_value_counter += 10
    else
      card_value_counter += 11
    end
  end
  
  #decided total based on total number of aces. Will keep adjusting ace value to 1 until the toal is 21 or under
  value_array.select { |v| v == 'Ace'}.count.times do
    card_value_counter -= 10 if card_value_counter > 21
  end
  
  card_value_counter
end

def is_bust?(total)
  if total > 21
    return true
  end
end

def is_dealer_sticking?(dealer_total)
  if dealer_total.between?(18,21)
    return true
  end
end

def compare_hands(name, player_bank_account, the_bet_value, player_card_value, dealer_card_value) 
  if player_card_value > dealer_card_value
    adjust_bank('win', player_bank_account, the_bet_value)
    print_string "Congratulations #{name}, you have won the game!"
  elsif player_card_value < dealer_card_value
    adjust_bank('lose', player_bank_account, the_bet_value)
    print_string "Sorry #{name}, the dealer has won the game."
  else
    print_string "It's a tie! Have a go at beating the dealer again #{name}."
  end
end

def adjust_bank(win_lose, player_bank_account, the_bet_value)
  if win_lose == 'win'
    new_account_value = player_bank_account[0] + the_bet_value.to_i
    player_bank_account[0] = new_account_value
  else win_lose == 'lose'
    new_account_value = player_bank_account[0] - the_bet_value.to_i
    player_bank_account[0] = new_account_value
  end
end

def replenish_deck?(total_number_of_cards_played)
  if (total_number_of_cards_played > 120) || (total_number_of_cards_played == 0)
    true
  else
    false
  end
end

def blackjack(player_name, bank, game_deck, player_cards, dealer_cards)
  puts `clear`

  begin
   print_string "Place your bet! You have £#{bank[0]} in your account"
   bet_placed = gets.chomp
  end while !valid_value?(bet_placed, bank)
  
  2.times { player_cards << deal_a_card(game_deck) }
  2.times { dealer_cards << deal_a_card(game_deck) }
  
  ###players turn###
  begin
    display_cards_on_table(player_cards, dealer_cards, player_name)
    player_total = card_total(player_cards)
    break if is_bust?(player_total)
  
    begin
      print_string "#{player_name}, would you like another card? Y or N"
      decision = gets.chomp
    end while !valid_decision?(decision)
  
    if decision.downcase == 'y'
      puts `clear`
      player_cards << deal_a_card(game_deck)
    end
  
  end while decision.downcase == 'y'

  if is_bust?(player_total)
    adjust_bank('lose', bank, bet_placed)
    print_string "#{player_name} is bust and has lost the game.  The dealer has won!"
    return
  end
  ###end of players turn###
  
  ###dealers turn###
  puts `clear`
  loop do
    dealer_total = card_total(dealer_cards)
    break if is_dealer_sticking?(dealer_total)
    print_string "   ********** The dealer is playing... **********"
    display_cards_on_table(player_cards, dealer_cards, player_name)
    sleep 2
    puts `clear`
    break if is_bust?(dealer_total)
    dealer_cards << deal_a_card(game_deck)
  end 
  
  display_cards_on_table(player_cards, dealer_cards, player_name)

  dealer_total = card_total(dealer_cards)
  if is_bust?(dealer_total)
    adjust_bank('win', bank, bet_placed)
    print_string "The dealer is bust and has lost the game. #{player_name} has won!"
    return
  end
  ###end of dealers turn###
  
  compare_hands(player_name, bank, bet_placed, player_total, dealer_total)
  
  return bank
end

puts `clear`
print_string "Welcome to this game of Blackjack.  Please enter your name:"
the_player_name = gets.chomp
print_string "You have £#{player_bank_account[0]} in your account. Let's play!"
sleep 2

begin
  puts `clear`
  if replenish_deck?(total_cards_played)
    game_deck = [deck_of_cards,deck_of_cards,deck_of_cards]
    total_cards_played = 0
    print_string "Getting the deck ready..."
    sleep 1
    print_string "waiting..."
    sleep 1
    print_string "Ready to play!"
    sleep 1
  end
  
  player_cards = []
  dealer_cards = []
  blackjack(the_player_name, player_bank_account, game_deck, player_cards, dealer_cards)

  total_cards_played = total_cards_played + player_cards.size + dealer_cards.size
  
  if player_bank_account[0] == 0
    print_string "Your account is empty...the house always wins!"
    break
  end

  begin
    print_string "Would you like to play again?: Y or N"
    decision = gets.chomp
  end while !valid_decision?(decision)
end while decision.downcase == 'y'
print_string "Thanks for playing #{the_player_name}"  