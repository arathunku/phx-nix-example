# Builds final release that should be put and runnable in docker image
inputs@{ self, pkgs, ... }:
let
  lib = pkgs.lib;
  # Use this if you'd like to tag docker images differently
  revision = "${self.lastModifiedDate}-${self.shortRev or "dirty"}";
  build = (pkgs.buildMix {
    pname = "demo_phx";
    version = "1.0.0-${revision}";
    src = self + "/demo_phx";
    # this value comes from coping it from the error on first build
    # it needs to be updated when dependencies change
    mixSha256 = "sha256-R0JTx/4fGYZaMBIq8VPaeEuT+57XlhoMVOAy+B/OQJU=";
    postUnpack = ''
      export ESBUILD_PATH=${pkgs.esbuild}/bin/esbuild
    '';
    # All packages are required to successfully run the release
    buildInputs =
      [ pkgs.erlang pkgs.bash pkgs.coreutils pkgs.gnugrep pkgs.gnused ];
  }).overrideAttrs (_: {
    preBuild = ''
      mix assets.deploy
    '';
  });
  buildImage = let
    port = "8000";
    # add buildInputs PATH otherwise they won't be accessible automatically
    path =
      "${lib.concatMapStrings (p: p + "/bin:") build.buildInputs}${build}/bin";
    useradd = "${pkgs.shadow}/bin/useradd";
    groupadd = "${pkgs.shadow}/bin/groupadd";
    entry-script = with pkgs;
      writeScript "entry-script.sh" ''
        #!${runtimeShell}
        set -e
        export LANG=en_US.utf8
        export PORT=${port}
        export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
        export PATH=${path}:$PATH
        echo $PATH

        # Avoids running the application as root
        ${groupadd} -r app
        ${useradd} -r -g app -M app

        ${pkgs.gosu}/bin/gosu app demo_phx start
      '';
  in pkgs.dockerTools.buildLayeredImage {
    tag = "latest";
    name = "demo_phx";
    created = "now";
    maxLayers = 124;
    config = {
      Cmd = [ "${entry-script}" ];
      ExposedPorts = { "${port}/tcp" = { }; };
    };
  };
in {
  build = build;
  image = buildImage;
}
