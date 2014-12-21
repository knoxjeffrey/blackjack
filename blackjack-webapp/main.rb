require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

BLACKJACK = 21
STICK_MIN = 17

helpers do
  def valid_name_entered?
    if session[:player_name] == ''
      @error = "You must enter a name"
    else
      session[:account] = 500
      redirect '/make_bet'
    end
  end
  
  def correct_money_entered?(the_bet_value, bank_account)
    if the_bet_value =~ /\D/
      @error = "You must enter a valid number"
    elsif the_bet_value.to_i == 0
      @error =  "You must enter a value higher than zero"
    elsif (bank_account - the_bet_value.to_i) < 0 
      @error =  "You do not have enough funds for that bet. Please enter a new bet"
    else
      session[:bet_made] = session[:bet_made].to_i
      redirect '/blackjack'
    end
  end
  
  def card_total(cards_held_array)
    value_array = cards_held_array.map { |v| v[1] }
    card_value_counter = 0
  
    value_array.each do |value|
      if value.is_a? Integer
        card_value_counter += value
      elsif value != 'A'
        card_value_counter += 10
      else
        card_value_counter += 11
      end
    end
  
    #decided total based on total number of aces. Will keep adjusting ace value to 1 until the toal is 21 or under
    value_array.select { |v| v == 'A'}.count.times do
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
      redirect '/game_result'
    elsif session[:dealer_card_hidden] == 'hidden'
      session[:dealer_card_hidden] = 'showing'
      @dealer_playing = true
    else
      session[:dealer_hand] << session[:deck].pop
      @dealer_playing = true
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

post '/submit_name' do
  session[:player_name] = params[:player_name]
  valid_name_entered?
  
  erb :home
end

get '/make_bet' do
  redirect '/' if !session[:player_name]
  erb :make_bet
end

post '/submit_bet' do
  session[:bet_made] = params[:bet_made]
  correct_money_entered?(session[:bet_made], session[:account])
 
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
  
  2.times { session[:player_hand] << session[:deck].pop }
  2.times { session[:dealer_hand] << session[:deck].pop }
  
  session[:stored_dealer_hand] = session[:dealer_hand]
  
  session[:dealer_hand] = [['dealer','cover'],session[:dealer_hand][1]]
  
  if card_total(session[:player_hand]) == BLACKJACK
    session[:account] += session[:bet_made]
    play_another_game
    winner("#{session[:player_name]} has Blackjack!")
  end
  
  erb :blackjack
end

post '/player_hit' do
  session[:player_hand] << session[:deck].pop
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
  erb :blackjack
end  

post '/player_stay' do
  session[:dealer_hand] = session[:stored_dealer_hand]
  @show_hit_stay_buttons = false
  dealer_playing
  
  erb :blackjack
end  

get '/dealer_hit' do
  @dealer_playing = false
  dealer_playing
  
  erb :blackjack
end

get '/game_result' do
  declare_result
  erb :blackjack
end

post '/play_again_yes_action' do
    redirect '/make_bet'
end

post '/play_again_no_action' do
  session[:player_name] = nil
  redirect '/'
end