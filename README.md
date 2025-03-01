# CCC Wallet

## Try it at local
1. Set up
```
make up
```

2. DB migrations
```
make db-migrate
```

3. Enter console
```
make app
```

4. Try the following commands
```
o = CCCWallet.new

ua = o.create_user(name: "user.a", email: "user.a@example.com")
ub = o.create_user(name: "user.b", email: "user.b@example.com")

o.deposit(ua.id, 100)
o.balance(ua.id)
# 0.1e3
o.withdraw(ua.id, 20)
o.balance(ua.id)
# 0.8e2

o.deposit(ub.id, 50)
o.balance(ub.id)
# 0.5e2

o.transfer(ub.id, ua.id, 50)
o.balance(ua.id)
# 0.13e3
o.balance(ub.id)
# 0.0
```

## How to use it in your projects
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
make up-infra
```

6. DB Migrations
Here are two options, if you are using ...
- Rails
    ```
    bin/rails db:migrate
    ```
- Non-Rails (`wallet` is changeable)
    ```
    migrate --database wallet
    ```

## Functional Requirements Check
- [x] User can deposit money into her wallet
- [x] User can withdraw money from her wallet
- [x] User can send money to another user
- [x] User can check her wallet balance
- [x] it’s a centralized wallet, not related to on chain implementation.
- [x] the Wallet App should keep track of all the users and wallets it contains
- [x] No UI interface is required, solution should be provided as reusable library code
- [x] submit your solution as a Zip file

## Non-functional Requirements
- `Strong Consistency`: Use `RDS`(MySQL) that fully supports `ACID` properties.
- `Reliability`: Avoid `deadlock` in a concurrency environment
    - EX: The userA transfers money to the userB, and the userB also transfers money to the userA at the same time.
- Others:
    - Simplify the database operation by leveraging Rails `Active::Record`
    - Order by wallet id when running `transfer` function to avoid the `Deadlock`
    - Support Rails and Non-Rails project to use and execute database migrations
        - Rails: Use `Rails Engine` to support `rails db:migrate`
        - Non-Rails: Use `bin/migrate` to migrate the database
    - Use `RSpec` to maintain test easily.

## Database Schema
`users`
```
CREATE TABLE `users` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    `email` varchar(255) NOT NULL,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `index_users_on_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
```

`wallets`
```
CREATE TABLE `wallets` (
    `id` bigint NOT NULL AUTO_INCREMENT,
    `user_id` bigint DEFAULT NULL,
    `balance` decimal(19,4) DEFAULT '0.0000',
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL,
    PRIMARY KEY (`id`),
    KEY `index_wallets_on_user_id` (`user_id`),
    CONSTRAINT `fk_rails_732f6628c4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
```