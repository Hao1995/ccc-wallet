require 'active_record'

class CreateUsersAndWalletsTable < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.timestamps
    end

    add_index :users, :email, unique: true

    create_table :wallets do |t|
      t.references :user, foreign_key: true
      t.decimal :balance, precision: 19, scale: 4, default: 0.0
      t.timestamps
    end
  end
end
