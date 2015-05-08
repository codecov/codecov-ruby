.PHONY: test install build deploy

build:
	gem build codecov.gemspec

deploy:
	gem push codecov-$(shell cat lib/codecov.rb | grep 'VERSION = ' | cut -d\" -f2).gem

install:
	rm -rf vendor .bundle
	bundle install

test:
	rake
