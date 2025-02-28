require 'spec_helper'
require_relative '../lib/ccc_wallet'

RSpec.describe CCCWallet do
  let(:app) { CCCWallet.new }
  let(:user1) { app.create_user(name: 'Alice', email: "alice_#{SecureRandom.uuid}@example.com") }
  let(:user2) { app.create_user(name: 'Bob', email: "bob_#{SecureRandom.uuid}@example.com") }

  before do
    user1.wallet.update(balance: 100.0)
    user2.wallet.update(balance: 50.0)
  end

  describe '#create_user' do
    it 'creates a new user with a wallet' do
      user = app.create_user(name: 'Charlie', email: 'charlie@example.com')
      expect(user).to be_persisted
      expect(user.wallet).not_to be_nil
      expect(user.wallet.balance).to eq(0.0)
    end
  end

  describe '#get_user' do
    it 'retrieves a user by ID' do
      retrieved_user = app.get_user(user1.id)
      expect(retrieved_user).to eq(user1)
    end
  end

  describe '#deposit' do
    it 'adds funds to the user wallet' do
      app.deposit(user1.id, 50.0)
      expect(user1.wallet.reload.balance).to eq(150.0)
    end
  end

  describe '#withdraw' do
    it 'deducts funds from the user wallet if sufficient balance' do
      app.withdraw(user1.id, 30.0)
      expect(user1.wallet.reload.balance).to eq(70.0)
    end

    it 'does not allow withdrawal if funds are insufficient' do
      expect { app.withdraw(user1.id, 200.0) }.to raise_error(StandardError, /Insufficient funds/)
    end
  end

  describe '#transfer' do
    it 'transfers funds between two users successfully' do
      app.transfer(user1.id, user2.id, 40.0)
      expect(user1.wallet.reload.balance).to eq(60.0)
      expect(user2.wallet.reload.balance).to eq(90.0)
    end

    it 'fails transfer if sender has insufficient funds' do
      expect { app.transfer(user1.id, user2.id, 200.0) }.to raise_error(StandardError, /Insufficient funds/)
    end
  end

  describe '#balance' do
    it 'returns the correct balance for a user' do
      expect(app.balance(user1.id)).to eq(100.0)
      expect(app.balance(user2.id)).to eq(50.0)
    end
  end
end
