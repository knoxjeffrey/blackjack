require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

BLACKJACK = 21
STICK_MIN = 17
ACCOUNT_AMOUNT = 500

helpers do  
  def valid_name_entered?
    return @error = "You must enter a name" if session[:player_name].empty? 
    session[:account] = ACCOUNT_AMOUNT 
    redirect '/make_bet'
  
  end
  
  def correct_money_entered?
    if session[:bet_made] =~ /\D/
      @error = "You must enter a valid number"
    elsif session[:bet_made].to_i == 0
      @error =  "You must enter a value higher than zero"
      halt erb(:make_bet)
    elsif (session[:account] - session[:bet_made].to_i) < 0 
      @error =  "You do not have enough funds for that bet. Please enter a new bet"
    else
      session[:bet_made] = session[:bet_made].to_i
      redirect '/blackjack'
    end
  end
  
  def match_card_image_name
    suit_and_value = session[:deck].pop
    
  	image_suit = case suit_and_value[0]
	
  	when 'H'
  		'hearts'
  	when 'D'
  		'diamonds'
  	when 'C'
  		'clubs'
  	when 'S'
  		'spades'
  	else
  		suit_and_value[0]
  	end
    
  	image_value = case suit_and_value[1]
		
  	when 'K'
  		'king'
  	when 'Q'
  		'queen'
  	when 'J'
  		'jack'
  	when 'A'
  		'ace'
  	else
  		suit_and_value[1]
  	end
    
    [image_value, image_suit]
    
  end
  
  def card_total(cards_held_array)
    value_array = cards_held_array.map { |card_array| card_array[0] }
    card_value_counter = 0
  
    value_array.each do |value|
      if value.is_a? Integer
        card_value_counter += value
      elsif value != 'ace'
        card_value_counter += 10
      else
        card_value_counter += 11
      end
    end
  
    #decided total based on total number of aces. Will keep adjusting ace value to 1 until the toal is 21 or under
    value_array.select { |value| value == 'ace'}.count.times do
      card_value_counter -= 10 if card_value_counter > BLACKJACK
    end
  
    card_value_counter
  end
  
  def is_dealer_sticking?(dealer_total)
    dealer_total.between?(STICK_MIN,BLACKJACK)
  end
  
  def is_dealer_bust?(dealer_total)
    if dealer_total > BLACKJACK
      true
    end
  end
  
  def winner(msg)
    @win = msg
  end
  
  def loser(msg)
    @lose = msg
  end
  
  def tied(msg)
    @tied = msg
  end
  
  def dealer_playing
    @show_hit_stay_buttons = false
    dealer_total = card_total(session[:dealer_hand])
    if is_dealer_bust?(dealer_total)
      session[:account] += session[:bet_made]
      winner("The dealer is bust. #{session[:player_name]} has won!")
      @show_yes_no_buttons = true
    elsif is_dealer_sticking?(dealer_total)
      redirect '/blackjack/game_result'
    elsif session[:dealer_card_hidden] == 'hidden'
      session[:dealer_card_hidden] = 'showing'
      @is_dealer_playing = true
    else
      session[:dealer_hand] << match_card_image_name
      @is_dealer_playing = true
    end
  end
  
  def play_another_game
    @show_hit_stay_buttons = false
    @show_yes_no_buttons = true
  end
  
  def declare_result
    if card_total(session[:player_hand]) > card_total(session[:dealer_hand])
      session[:account] += session[:bet_made]
      play_another_game
      winner("Congratulations #{session[:player_name]}, you have won the game!")
    elsif card_total(session[:player_hand]) < card_total(session[:dealer_hand])
      session[:account] -= session[:bet_made]
      play_another_game
      loser("Sorry #{session[:player_name]}, the dealer has won the game.")
    else
      play_another_game
      tied("It's a tie! Have a go at beating the dealer again #{session[:player_name]}.")
    end
  end
end

before do
  @show_hit_stay_buttons = true
  @show_yes_no_buttons = false
  @dealer_card_hidden = true
end

get '/' do
  redirect '/make_bet' if session[:player_name]
  erb :home
end

get '/home' do
  session[:player_name] = nil
  redirect '/'
end

post '/' do
  session[:player_name] = params[:player_name]
  valid_name_entered?
  
  erb :home
end

get '/make_bet' do
  redirect '/' if !session[:player_name]
  erb :make_bet
end

post '/make_bet' do
  session[:bet_made] = params[:bet_made]
  correct_money_entered?
 
  erb :make_bet
end

get '/blackjack' do
  redirect '/' if !session[:player_name]
  
  session[:dealer_card_hidden] = 'hidden'
  
  suits = ['H', 'D', 'S', 'C']
  values = ['A',2,3,4,5,6,7,8,9,'J','Q','K']
  session[:deck] = suits.product(values).shuffle!
  
  session[:player_hand] = []
  session[:dealer_hand] = []
  
  2.times {session[:player_hand] << match_card_image_name}
  2.times {session[:dealer_hand] << match_card_image_name}
  
  session[:stored_dealer_hand] = session[:dealer_hand]
  
  session[:dealer_hand] = [['cover', 'dealer'], session[:dealer_hand][1]]
  
  if card_total(session[:player_hand]) == BLACKJACK
    session[:account] += session[:bet_made]
    play_another_game
    winner("#{session[:player_name]} has Blackjack!")
  end
  
  erb :blackjack
end

post '/blackjack/player_hit' do
  session[:player_hand] << match_card_image_name
  if (card_total(session[:player_hand]) > BLACKJACK) && (session[:account] - session[:bet_made] == 0)
    session[:account] -= session[:bet_made]
    @show_hit_stay_buttons = false
    loser("Sorry #{session[:player_name]}, you lost and are out of cash. Restart game to have another go.")
    session[:player_name] = nil
  elsif card_total(session[:player_hand]) > BLACKJACK
    play_another_game
    loser("#{session[:player_name]} is bust and has lost the game.")
    session[:account] -= session[:bet_made]
  end
  erb :blackjack, layout: false
end  

post '/blackjack/player_stay' do
  session[:dealer_hand] = session[:stored_dealer_hand]
  @show_hit_stay_buttons = false
  redirect '/blackjack/dealer'
  
  erb :blackjack, layout: false
end  

get '/blackjack/dealer' do
  @is_dealer_playing = false
  dealer_playing
  
  erb :blackjack, layout: false
end

get '/blackjack/game_result' do
  declare_result
  erb :blackjack, layout: false
end

post '/blackjack/play_again_yes_action' do
    redirect '/make_bet'
end

post '/blackjack/play_again_no_action' do
  session[:player_name] = nil
  redirect '/'
end