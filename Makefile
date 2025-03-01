.PHONY: build, install

build:
	gem build ccc_wallet.gemspec

install:
	gem install ./ccc_wallet-1.0.0.gem

up-infra:
	docker-compose up -d --build

down-infra:
	docker-compose down

up:
	docker-compose --profile app up -d --build

down:
	docker-compose --profile app down

db-migrate:
	docker-compose exec app bash -c "bundle exec rake db:migrate"

test:
	docker-compose exec app bash -c "bundle exec rspec"

app:
	docker-compose exec app bash -c "irb -r './lib/ccc_wallet.rb'"
