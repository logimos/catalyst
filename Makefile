init:
	mix new catalyst --module Catalyst

compile:
	mix compile

test:
	mix test

clean:
	rm -rf _build
	rm -rf deps
	rm -rf .mix
	rm -rf .elixir_ls

run:
	mix catalyst.new

build-archive:
	mix archive.build

install-archive:
	mix archive.install ./catalyst-0.1.0.ez

## run mix catalyst.new


