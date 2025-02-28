class User < ActiveRecord::Base
  has_one :wallet, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  after_create :create_wallet

  private

  def create_wallet
    Wallet.create(user: self, balance: 0)
  end
end
