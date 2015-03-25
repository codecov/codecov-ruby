.PHONY: test install build deploy

build:
	gem build codecov.gemspec

deploy:
	gem push codecov-0.0.4.gem

install:
	rm -rf vendor .bundle
	bundle install

test:
	rake
