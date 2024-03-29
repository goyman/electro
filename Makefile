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

assets: export MIX_ENV=dev
assets:
	mix assets.deploy

.PHONY: release

release: export MIX_ENV=prod
release: assets
	mix phx.digest
	mix release --overwrite

.PHONY: deploy

deploy: release install

.PHONY: install

install:
	systemctl --user stop electro
	mkdir -p /home/kuon/Apps/electro/app/
	rsync -avP _build/prod/rel/electro/ /home/kuon/Apps/electro/app/
	systemctl --user start electro
