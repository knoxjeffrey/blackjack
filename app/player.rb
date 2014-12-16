class Player
  include Hand
  
  attr_reader :name, :account
  attr_accessor :cards_held
  
  def initialize(name, amount_in_bank)
    @name = name
    @account = Bank.new(amount_in_bank)
    @cards_held = []
  end
  
  def amount_in_account
    account.bank
  end
  
  def win_money(amount)
    account.deposit_money(amount)
  end
  
  def lose_money(amount)
    account.withdraw_money(amount)
  end
end