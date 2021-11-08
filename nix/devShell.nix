# Sets up env keys and dependencies for local development

input@{ lib, pkgs, inotify-tools, bash, libnotify, mkShell, stdenv, elixir
, erlang, postgresql, hex, rebar3 }:
let
in mkShell rec {
  name = "phx-nix";

  packages = [ bash elixir erlang postgresql hex rebar3 ]
    ++ lib.optionals stdenv.isLinux [ inotify-tools libnotify ];
  PGHOST = "localhost";
  PGPORT = "5432";
  POOL_SIZE = 15;
  PGDATABASE = "noop";
  PGUSER = "postgres";
  PGPASSWORD = "postgres";
  DATABASE_URL =
    "postgresql://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}/${PGDATABASE}?sslmode=disable";
  ERL_AFLAGS = "-kernel shell_history enabled";
  MIX_REBAR3 = "${rebar3.outPath}/bin/rebar3";

  shellHook = ''
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex
    mkdir -p $MIX_HOME
    mkdir -p $HEX_HOME
    export ESBUILD_PATH=${pkgs.esbuild}/bin/esbuild
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    export PGDATA="$PWD/db"
  '';

}
