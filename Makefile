.PHONY: test install build deploy

build:
	gem build codecov.gemspec

deploy:
	$(eval VERSION := $(shell cat lib/codecov.rb | grep 'VERSION = ' | cut -d\" -f2))
	git tag v$(VERSION) -m ""
	git push origin v$(VERSION)
	gem push codecov-$(VERSION).gem

install:
	rm -rf vendor .bundle
	bundle install

test:
	rake
