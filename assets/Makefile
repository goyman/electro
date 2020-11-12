SHELL := /bin/sh
PATH := ./node_modules/.bin:$(PATH)


.PHONY: build

build: export NODE_ENV=production
build: node_modules
	webpack --mode production

.PHONY: watch

watch: node_modules
	webpack --color --mode development --watch

.PHONY: clean

clean:
	rm -fr node_modules
	rm -fr ../priv/static/
	rm -fr npm-debug.log*

yarn.lock:
	yarn

node_modules: yarn.lock package.json
	yarn
