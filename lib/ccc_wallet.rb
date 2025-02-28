require 'active_record'
require 'logger'
require "engine"
require_relative 'models/user'
require_relative 'models/wallet'

# CCCWallet is a simple centralized wallet system that allows users to:
# - Create an account
# - Deposit funds into their wallet
# - Withdraw funds from their wallet
# - Transfer funds to another user's wallet
# - Check their current wallet balance
class CCCWallet
  def create_user(params)
    User.create!(params.slice(:name, :email))
  end

  def get_user(user_id)
    User.find(user_id)
  end

  def deposit(user_id, amount)
    get_user(user_id).wallet.deposit(amount)
  end

  def withdraw(user_id, amount)
    get_user(user_id).wallet.withdraw(amount)
  end

  def transfer(sender_id, receiver_id, amount)
    sender_wallet = get_user(sender_id).wallet
    receiver_wallet = get_user(receiver_id).wallet
    sender_wallet.transfer_to(receiver_wallet, amount)
  end

  def balance(user_id)
    get_user(user_id).wallet.balance
  end
end
