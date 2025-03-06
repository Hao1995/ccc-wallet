class Wallet < ActiveRecord::Base
  belongs_to :user

  validates :balance, numericality: { greater_than_or_equal_to: 0 }

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
    ActiveRecord::Base.transaction do
      raise ArgumentError, "Withdrawal amount must be positive" if amount <= 0
      raise StandardError, "Insufficient funds" if amount > balance

      if self.id < recipient_wallet.id
        update!(balance: balance - amount)
        recipient_wallet.update!(balance: recipient_wallet.balance + amount)
      else
        recipient_wallet.update!(balance: recipient_wallet.balance + amount)
        update!(balance: balance - amount)
      end
    end
  end
end
