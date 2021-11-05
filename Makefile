.PHONY: server

server: deps
	iex -S mix phx.server


.PHONY: deps

deps:
	mix deps.get

.PHONY: clean

clean:
	cd assets && make clean
	rm -fr _build
	rm -fr deps
	rm -fr erl_crash.dump

.PHONY: assets

assets:
	cd assets && make build

.PHONY: assets-watch

assets-watch:
	cd assets && make watch

.PHONY: release

release: export MIX_ENV=prod
release: assets
	mix phx.digest
	mix release --overwrite
