build:
	gem build codecov.gemspec

deploy:	
	gem push codecov-0.0.1.gem

install:
	bundle install

test:
	rake

p:
	irb
