require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do
  def correct_money_entered?(the_bet_value, bank_account)
    if the_bet_value =~ /\D/
      @error = "You must enter a valid number"
    elsif the_bet_value.to_i == 0
      @error =  "You must enter a value higher than zero"
    elsif (bank_account - the_bet_value.to_i) < 0 
      @error =  "You do not have enough funds for that bet. Please enter a new bet"
    else
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
      card_value_counter -= 10 if card_value_counter > 21
    end
  
    card_value_counter
  end
end

before do
  @show_hit_stay_buttons = true
  @show_yes_no_buttons = false
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
  session[:account] = 500
  redirect '/make_bet'
end

get '/make_bet' do
  redirect '/' if !session[:player_name]
  erb :make_bet
end

post '/submit_bet' do
  session[:bet_made] = params[:bet_made].to_i
  correct_money_entered?(session[:bet_made], session[:account])
 
  erb :make_bet
end

get '/blackjack' do
  redirect '/' if !session[:player_name]
  
  suits = ['H', 'D', 'S', 'C']
  values = ['A',2,3,4,5,6,7,8,9,'J','Q','K']
  session[:deck] = suits.product(values).shuffle!
  
  session[:player_hand] = []
  session[:dealer_hand] = []
  
  2.times { session[:player_hand] << session[:deck].pop }
  2.times { session[:dealer_hand] << session[:deck].pop }
  
  if card_total(session[:player_hand]) == 21
    session[:account] += session[:bet_made]
    @show_hit_stay_buttons = false
    @show_yes_no_buttons = true
    @stick = "#{session[:player_name]} has Blackjack!"
  end
  
  erb :blackjack
end

post '/player/hit' do
  session[:player_hand] << session[:deck].pop
  if (card_total(session[:player_hand]) > 21) && (session[:account] - session[:bet_made] == 0)
    @show_hit_stay_buttons = false
    @account_empty = "Sorry #{session[:player_name]}, you lost and are out of cash. Restart game to have another go."
    session[:player_name] = nil
  elsif card_total(session[:player_hand]) > 21
    @show_hit_stay_buttons = false
    @show_yes_no_buttons = true
    @bust = "#{session[:player_name]} is bust and has lost the game."
    session[:account] -= session[:bet_made]
  end
  erb :blackjack
end  

post '/player/stay' do
  @show_hit_stay_buttons = false
  @stick = "#{session[:player_name]} is sticking. Time for the dealer to play."
  erb :blackjack
end  

post '/play_again_yes_action' do
    redirect 'make_bet'
end

post '/play_again_no_action' do
  session[:player_name] = nil
  redirect '/'
end
  
  
  