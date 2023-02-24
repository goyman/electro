PATH := ./node_modules/.bin:$(PATH)
JS_SOURCE:=$(shell find js -name \*.js)
JS_SOURCE+=tailwind.config.js

.PHONY: clean

clean:
	rm -fr ../priv/static/assets
	rm -fr node_modules

deps: node_modules

node_modules:
	npm i

.PHONY: format

format: deps
	-eslint $(JS_SOURCE) --fix
