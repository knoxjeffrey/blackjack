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
  redirect '/make_bet'
end

get '/make_bet' do
  redirect '/' if !session[:player_name]
  session[:account] = 500
  erb :make_bet
end

post '/submit_bet' do
  session[:bet_made] = params[:bet_made]
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
  
  erb :blackjack
end

post '/player/hit' do
  
  erb :blackjack
end  

post '/player/stay' do
  
  erb :blackjack
end  
  
  
  