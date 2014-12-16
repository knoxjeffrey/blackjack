class GameFlow
  
  require_relative 'text_format'
  require_relative 'money_checker'
  require_relative 'hand_total'
  
  include TextFormat
  include MoneyChecker
  include HandTotal
  
  NUMBER_OF_DECKS_FOR_GAME = 3
  BLACKJACK_AMOUNT = 21
  
  attr_reader :player, :dealer, :blackjack_deck
  attr_accessor :bet_placed
  
  def initialize
    puts `clear`
    TextFormat.print_string "Welcome to this game of Blackjack.  Please enter your name:"
    player_name = TextFormat.chomp_it
    
    @player = Player.new(player_name,100)
    @dealer = Dealer.new('Kryton')
    @blackjack_deck = DeckHandler.new
    @bet_placed = 0
  end
  
  def show_cards_on_table(dealer_cards_held, player_cards_held)
    TextFormat.print_string "The dealers cards are:"
    blackjack_deck.display_cards(dealer_cards_held)
  
    TextFormat.print_string "#{player.name}'s cards are:"
    blackjack_deck.display_cards(player_cards_held)
  end
  
  def game_setup
    TextFormat.print_string "#{player.name} you have £#{player.amount_in_account} in your account. Let's play!"
  
    puts `clear`
    if (blackjack_deck.game_deck.size == 0) || (blackjack_deck.game_deck.size <= 30)
      blackjack_deck.replenish_deck(NUMBER_OF_DECKS_FOR_GAME)

      TextFormat.print_string "...New deck is ready"
      sleep 2
    end
  
    puts `clear`
    player.clear_hand
    dealer.clear_hand
    begin
      TextFormat.print_string "Place your bet! You have £#{player.amount_in_account} in your account"
      self.bet_placed = gets.chomp
    end while !MoneyChecker.correct_money_entered?(bet_placed, player.amount_in_account)
  
    puts `clear`
  
    2.times { player.receive_card(blackjack_deck.deal_card) }
    2.times { dealer.receive_card(blackjack_deck.deal_card) }
  
    dealer_hand_with_hole_card = [blackjack_deck.unturned_card, dealer.cards_held[1]]
    show_cards_on_table(dealer_hand_with_hole_card, player.cards_held)
   
  end
  
  def blackjack_on_first_draw?
    if HandTotal.card_total(player.cards_held) == BLACKJACK_AMOUNT
      TextFormat.print_string "Well done #{player.name}, you have won the game!"
      player.win_money(bet_placed.to_i)
      true 
    end
  end
  
  def is_player_bust?(hand_held)
    if HandTotal.card_total(hand_held) > BLACKJACK_AMOUNT
      player.lose_money(bet_placed.to_i)
      TextFormat.print_string "#{player.name} is bust and has lost the game.  #{dealer.name} has won!"
      true
    end
  end
  
  def is_dealer_bust?(hand_held)
    if HandTotal.card_total(hand_held) > BLACKJACK_AMOUNT
      player.win_money(bet_placed.to_i)
      TextFormat.print_string "The dealer is bust. #{player.name} has won!" 
      true
    end
  end
  
  def player_round
    begin
      dealer_hand_with_hole_card = [blackjack_deck.unturned_card, dealer.cards_held[1]]
      show_cards_on_table(dealer_hand_with_hole_card, player.cards_held)
      break if HandTotal.card_total(player.cards_held) > BLACKJACK_AMOUNT
    
      begin
        TextFormat.print_string "#{player.name}, would you like another card? Y or N"
        decision = gets.chomp
      end while !TextFormat.entered_correct_choice?(decision)
    
      if decision.downcase == 'y'
        puts `clear`
        player.receive_card(blackjack_deck.deal_card)
      end

    end while decision.downcase == 'y'
  end
  
  def dealer_round
    puts `clear`
    loop do
      TextFormat.print_string "   ********** The dealer is playing... **********"
      show_cards_on_table(dealer.cards_held, player.cards_held)
      dealer_total = HandTotal.card_total(dealer.cards_held)
      break if dealer.is_dealer_sticking?(dealer_total)
      break if HandTotal.card_total(dealer.cards_held) > BLACKJACK_AMOUNT
      sleep 2
      puts `clear`

      dealer.receive_card(blackjack_deck.deal_card)
    end 
  end
  
  def declare_result(bet_placed)
    if HandTotal.card_total(player.cards_held) > HandTotal.card_total(dealer.cards_held)
      player.win_money(bet_placed)
      TextFormat.print_string "Congratulations #{player.name}, you have won the game!"
    elsif HandTotal.card_total(player.cards_held) < HandTotal.card_total(dealer.cards_held)
      player.lose_money(bet_placed)
      TextFormat.print_string "Sorry #{player.name}, the dealer has won the game."
    else
      TextFormat.print_string "It's a tie! Have a go at beating the dealer again #{player.name}."
    end
  end
  
  def game_sequence
    
      game_setup
      return if blackjack_on_first_draw?
  
      puts `clear`
  
      player_round
      return if is_player_bust?(player.cards_held)
    
      dealer_round
      return if is_dealer_bust?(dealer.cards_held)
      
      sleep 1
      puts `clear`
      show_cards_on_table(dealer.cards_held, player.cards_held)
  
      declare_result(bet_placed.to_i)
  end
  
  def game
    begin
      if player.amount_in_account == 0
        TextFormat.print_string "Your account is empty...the house always wins!"
        TextFormat.print_string "Thanks for playing #{player.name}" 
        return
      end
      
      game_sequence

      begin
        TextFormat.print_string "Would you like to play again?: Y or N"
        decision = gets.chomp
      end while !TextFormat.entered_correct_choice?(decision)
    end while decision.downcase == 'y'
  
    TextFormat.print_string "Thanks for playing #{player.name}" 
  end
end