# Elixir Phoenix Nix demo

This repo contains basic Phoenix application and nix code required to
be able to run the app locally and build docker image for a docker-based deployment.

I strongly suggest to use [nix-direnv](https://github.com/nix-community/nix-direnv) for
a bit nicer development UX.

Structure:

- ./demo_phx - main app generated with `mix phx.new demo_phx --live`
- ./nix - nix code required to set everything up
- ./bin - additional scripts to run postgres (installed via Nix too) and
  build docker image

## Nix

This repo uses [Nix flakes](https://nixos.wiki/wiki/Flakes).

Docker images building is currently skipped for MacOS,
everything else should work.

There's a lot of boilerplate in flake.nix, the 'meat' is in ./nix.

## Phoenix app

There are only 3 changes vs what's generated.

First one is related to `esbuild`, I wanted to avoid any repeated downloads when
building docker image so there's additional env variable pointing to esbuild.
The tool itself is downloaded via nix.


- `config/config.exs`
```diff
config :esbuild,
  version: "0.12.18",
+ path: System.get_env("ESBUILD_PATH"),
  default: [
    args:
      ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
-   env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
+   env: %{"NODE_PATH" => Path.expand(System.get_env("MIX_DEPS_PATH", "../deps"), __DIR__)}
  ]
```
Second change visible above is related to location of dependencies,
during docker image build they're in a different location (nix store), so
without this change esbuild wouldn't be able to resolve Phoenix JS libraries.

Third change is unique to my set up and might be skipped, it's a binding to
IPv4 instead to IPv6 in `config/runtime.exs`.


## Why have I done this?

I wanted to learn a bit of Nix and see for myself how hard it would be to
use Nix to manage both local and docker based production build without a lot of
duplication.


## Running

```bash
$ ls -a
.envrc  .git  .gitignore  bin  demo_phx  flake.lock  flake.nix  nix  README.md
$ nix develop
$ ls -a
.envrc  .git  .gitignore  .nix-hex  .nix-mix  bin  demo_phx  flake.lock  flake.nix  nix  README.md
```
Basic directories are automatically created and now you have required dependencies in $PATH

Let's create db and run tests
```bash
$ db-run
$ cd demo_phx
$ mix test

Finished in 0.03 seconds (0.03s async, 0.00s sync)
3 tests, 0 failures
```
Everything should pass successfully.


### Docker image

```bash
# building
$ bin/ci-image
# running
$ docker run --rm -e DATABASE_URL="$DATABASE_URL" -e SECRET_KEY_BASE="AAS+PPF6mkBp1" --network host phx-nix:latest
```

In the command above, you'll notice network mode `host` is used,
this is because it connects to postgres instance running locally.


--------------------------

If you have any suggestions how to simplify code here -
please open an issue or send me an email.
