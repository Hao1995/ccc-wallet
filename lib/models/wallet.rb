class Wallet < ActiveRecord::Base
  belongs_to :user

  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def deposit(amount)
    raise ArgumentError, "Deposit amount must be positive" if amount <= 0
    with_lock do
      update!(balance: balance + amount)
    end
  end

  def withdraw(amount)
    raise ArgumentError, "Withdrawal amount must be positive" if amount <= 0
    raise StandardError, "Insufficient funds" if amount > balance
    with_lock do
      raise StandardError, "Insufficient funds" if amount > balance
      update!(balance: balance - amount)
    end
  end

  def transfer_to(recipient_wallet, amount)
    wallets = [self, recipient_wallet].sort_by(&:id)

    ActiveRecord::Base.transaction do
      wallets.each { |wallet| wallet.lock! }

      reload
      recipient_wallet.reload

      raise ArgumentError, "Withdrawal amount must be positive" if amount <= 0
      raise StandardError, "Insufficient funds" if amount > balance
      update!(balance: balance - amount)
      recipient_wallet.update!(balance: recipient_wallet.balance + amount)
    end
  end
end
