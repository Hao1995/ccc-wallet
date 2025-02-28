class Wallet < ActiveRecord::Base
  belongs_to :user

  def deposit(amount)
    raise ArgumentError, "Deposit amount must be positive" if amount <= 0
    update!(balance: balance + amount)
  end

  def withdraw(amount)
    raise ArgumentError, "Withdrawal amount must be positive" if amount <= 0
    raise StandardError, "Insufficient funds" if amount > balance
    update!(balance: balance - amount)
  end

  def transfer_to(recipient_wallet, amount)
    raise ArgumentError, "Transfer amount must be positive" if amount <= 0
    raise StandardError, "Insufficient funds" if amount > balance

    ActiveRecord::Base.transaction do
      withdraw(amount)
      recipient_wallet.deposit(amount)
    end
  end
end
