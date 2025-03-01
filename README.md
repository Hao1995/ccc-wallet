# CCC Wallet

## How to use it?
1. Generate the gem file:
```
gem build ccc_wallet.gemspec
# Output: ccc_wallet-1.0.0.gem
```

2. Install the gem file
```
gem install ./ccc_wallet-1.0.0.gem
```

3. Add the following to your Gemfile in your project
```
gem 'ccc_wallet', '1.0.0'
```

4. Run `bundle install`
```
bundle install
```

5. Please prepare well your database connection (in our case, we use MySQL)
You can manually create your own MySQL database or run docker-compose in the current library's directory.
```
docker-compose up -d
```

6. DB Migrations
Here are two options, if you are using ...
1. Rails
```
bin/rails db:migrate
```
2. Non-Rails (`wallet` is changeable)
```
migrate --database wallet
```

## Thought process
* Simplify the application by leveraging Rails `Active::Record` to operate with database and leverage built-in [optimistic locking](https://api.rubyonrails.org/classes/ActiveRecord/Locking/Optimistic.html).
    * Sample Query (for Deposit, Withdraw, and Transfer. Update with lock_version):
    ```
    UPDATE `wallets` SET `wallets`.`balance` = 40.0, `wallets`.`updated_at` = '2025-03-01 03:02:44.572360', `wallets`.`lock_version` = 2 WHERE `wallets`.`id` = 252 AND `wallets`.`lock_version` = 1`
    ```
* Use Rails Engine to separate the Wallet APP as an independent module.
    * When running `rails db:migrate`, we can seamlessly use the migrations from the package.
* Use `bin/migrate` to support Non-Rails projects to migrate the database.
* Use RSpec to maintain test easily.

## Project layout
How should reviewer view your code:
* lib: It is used for placing core business code.
    * models: database entities
* db
    * migrate: database migration files
* spec: test cases

## Areas to be improved
* Add linter(RuboCop)
* Test Coverage
* CICD

## Spent time
Spent time: 6h.
I spent more time on familiar developing a gem lib and support different database migration approaches,
also test it by creating example application.