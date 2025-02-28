require 'spec_helper'
require_relative '../lib/user'
require_relative '../lib/wallet'

RSpec.describe Wallet, type: :model do
  before(:each) do
    Wallet.delete_all
    User.delete_all
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
  end

  describe 'optimistic locking' do
    it 'raises an ActiveRecord::StaleObjectError when concurrent updates occur' do
      wallet.deposit(100.0)

      error_occurred = false

      thread_a = Thread.new do
        ActiveRecord::Base.transaction do
          wallet_a = Wallet.find(wallet.id)
          wallet_a.withdraw(60.0)
          sleep(0.5)
          wallet_a.save!
        rescue ActiveRecord::StaleObjectError
          error_occurred = true
        end
      end

      thread_b = Thread.new do
        ActiveRecord::Base.transaction do
          wallet_b = Wallet.find(wallet.id)
          wallet_b.withdraw(70.0)
          wallet_b.save!
        rescue ActiveRecord::StaleObjectError
          error_occurred = true
        end
      end

      thread_a.join
      thread_b.join

      expect(error_occurred).to be true
    end
  end
end
