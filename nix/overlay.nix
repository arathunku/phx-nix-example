final: prev:
let
  beam = prev.beam_minimal;
  packages = beam.packages.erlangR24;
in rec {
  inherit beam;

  # Forces erlang and elixer version.
  # It uses beam_minimal to avoid systemd and wxwidgets as dependencies
  # resulting in a much smaller final docker image
  erlang = beam.interpreters.erlangR24;
  elixir = packages.elixir_1_12;
  hex = packages.hex.override { inherit elixir; };
  rebar3 = packages.rebar3;
  buildMix =
    prev.beam.packages.erlang.buildMix'.override { inherit elixir erlang hex; };

  # skip most of the locales - smaller docker image
  glibcLocales = if prev.stdenv.hostPlatform.libc == "glibc" then
    prev.glibcLocales.override { allLocales = false; }
  else
    null;
  postgresql = prev.postgresql_14;

  devShell = final.callPackage ./devShell.nix { };
}
