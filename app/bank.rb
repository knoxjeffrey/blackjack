class Bank
  attr_accessor :bank
  
  def initialize(how_much_in_account)
    @bank = how_much_in_account
  end
  
  def deposit_money(amount)
    self.bank += amount
  end
  
  def withdraw_money(amount)
    self.bank -= amount
  end
end