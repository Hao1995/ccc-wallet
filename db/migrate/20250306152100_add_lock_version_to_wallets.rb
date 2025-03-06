require 'active_record'

class AddLockVersionToWallets < ActiveRecord::Migration[8.0]
  def change
    add_column :wallets, :lock_version, :integer, after: :balance
  end
end
