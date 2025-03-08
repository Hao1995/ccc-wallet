require 'spec_helper'
require_relative '../../lib/models/user'
require_relative '../../lib/models/wallet'

RSpec.describe Wallet, type: :model do
  before do
    DatabaseCleaner.clean
  end

  let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
  let(:wallet) { user.wallet }

  describe '#deposit' do
    it 'increases the wallet balance by the deposited amount' do
      wallet.deposit(100.0)
      expect(wallet.balance.to_f).to eq(100.0)
    end

    it 'raises an error for non-positive deposit amounts' do
      expect { wallet.deposit(0) }.to raise_error(ArgumentError)
      expect { wallet.deposit(-10) }.to raise_error(ArgumentError)
    end
  end

  describe '#withdraw' do
    before { wallet.deposit(200.0) }

    it 'decreases the wallet balance by the withdrawn amount' do
      wallet.withdraw(50.0)
      expect(wallet.balance.to_f).to eq(150.0)
    end

    it 'raises an error for non-positive withdrawal amounts' do
      expect { wallet.withdraw(0) }.to raise_error(ArgumentError)
      expect { wallet.withdraw(-10) }.to raise_error(ArgumentError)
    end

    it 'raises an error when withdrawing more than the balance' do
      expect { wallet.withdraw(250.0) }.to raise_error(StandardError, /Insufficient funds/)
    end
  end

  describe '#transfer_to' do
    let(:recipient) { User.create!(name: 'Recipient', email: 'recipient@example.com') }
    let(:recipient_wallet) { recipient.wallet }

    before { wallet.deposit(300.0) }

    it 'transfers the specified amount from one wallet to another' do
      wallet.transfer_to(recipient_wallet, 150.0)
      expect(wallet.balance.to_f).to eq(150.0)
      expect(recipient_wallet.balance.to_f).to eq(150.0)
    end

    it 'raises an error when the transfer amount is non-positive' do
      expect { wallet.transfer_to(recipient_wallet, 0) }.to raise_error(ArgumentError)
      expect { wallet.transfer_to(recipient_wallet, -50) }.to raise_error(ArgumentError)
    end

    it 'raises an error when transferring more than the available funds' do
      expect { wallet.transfer_to(recipient_wallet, 400.0) }.to raise_error(StandardError, /Insufficient funds/)
    end

    it 'handles concurrent transfers between two wallets' do
      user_a = User.create!(name: 'User A', email: 'user_a@example.com')
      user_b = User.create!(name: 'User B', email: 'user_b@example.com')

      user_a.wallet.deposit(300.0)
      user_b.wallet.deposit(300.0)

      def transfer(sender_id, receiver_id, amount)
        sender_wallet = Wallet.find_by(user_id: sender_id)
        receiver_wallet = Wallet.find_by(user_id: receiver_id)
        sender_wallet.transfer_to(receiver_wallet, amount)
      end

      threads = []
      errors = []

      threads << Thread.new do
        transfer(user_a, user_b, 100.0)
      rescue => e
        errors << e
      end

      threads << Thread.new do
        transfer(user_b, user_a, 150.0)
      rescue => e
        errors << e
      end

      threads.each(&:join)

      expect(errors).to include(an_instance_of(ActiveRecord::StaleObjectError)).or include(an_instance_of(ActiveRecord::Deadlocked)).or be_empty

      # Only one transaction can be finished
      # Case: if the transfer from wallet_a success (100.0)
      # wallet_a.balance = 200 && wallet_b.balance = 400
      # Case: if the transfer from wallet_b success (150.0)
      # wallet_a.balance = 450 && wallet_b.balance = 150
      # Case: both transfer are success
      # wallet_a.balance = 350 && wallet_b.balance = 250
      expect(user_a.wallet.reload.balance.to_f).to eq(200.0).or eq(450).or eq(350)
      expect(user_b.wallet.reload.balance.to_f).to eq(400.0).or eq(150).or eq(250)
    end
  end
end
