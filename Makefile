# Run tests
test:
	bundle exec rspec

# Run RuboCop linting
lint:
	bundle exec rubocop

# Run RuboCop with auto-correction
lint-fix:
	bundle exec rubocop -a

# Run tests and lint together
check:
	bundle exec rspec
	bundle exec rubocop
