.PHONY: test install build deploy

deploy:
	$(eval VERSION := $(shell cat lib/codecov.rb | grep 'VERSION = ' | cut -d\' -f2))
	git tag v$(VERSION) -m ""
	git push origin v$(VERSION)
	gem build codecov.gemspec
	gem push codecov-$(VERSION).gem

install:
	rm -rf vendor .bundle
	bundle install

test:
	bundle exec rake

compare:
	hub compare $(shell git tag --sort=refname | tail -1)...master
