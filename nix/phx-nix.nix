{ lib, beam, inotify-tools, bash, libnotify, postgresql_14, mkShell, stdenv }:
let
  elixir = beam.packages.erlangR24.elixir_1_12;
  hex = beam.packages.erlangR24.hex;
  rebar3 = beam.packages.erlangR24.rebar3;

in mkShell rec {
  name = "phx-nix";

  packages = [ elixir hex rebar3 postgresql_14 bash ] ++ lib.optionals stdenv.isLinux [
    inotify-tools
    libnotify
    # in case something should be available only on linux
  ];
  PGHOST = "localhost";
  PGPORT = "5432";
  POOL_SIZE = 15;
  PGDATABASE = "noop";
  PGUSER = "postgres";
  PGPASSWORD = "postgres";
  DATABASE_URL =
    "postgresql://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}/${PGDATABASE}?sslmode=disable";
  ERL_AFLAGS = "-kernel shell_history enabled";
  SSS = "${builtins.trace rebar3 ""}";
  DEV_MIX_REBAR = "${rebar3.outPath}";
  DEV_MIX_REBAR1 = "ixxxx";
  # MIX_REBAR = "${rebar3.bin}";

  shellHook = ''
    mkdir -p .nix-mix
    mkdir -p .nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export MIX_REBAR3=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    export PGDATA="$PWD/db"
    alias db-start="pg_ctl -l \"$PGDATA/server.log\" start"
  '';

}
