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

3. Add the following to your Gemfile in your Rails project
```
gem 'ccc_wallet', '1.0.0'
```

4. Run `bundle install`
```
bundle install
```

5. Please prepare well your database connection configuration (in our case, I use MySQL)
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
2. Non-Rails
```
migrate --database wallet # `wallet` is changeable
```

## Thought process
* Simplify the application by leveraging Rails `Active::Record` to operate with database and leverage built-in [optimistic locking](https://api.rubyonrails.org/classes/ActiveRecord/Locking/Optimistic.html).
* Use Rails Engine to separate the Wallet APP as an independent module.
    * When running `rails db:migrate`, we can seamlessly use the migrations from the package.
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
* Decouple from Rails (due to Rails Engine)