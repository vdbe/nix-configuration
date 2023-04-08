{ lib, stdenv, writers, jre, ... }:

let
  name = "maelstrom";
  version = "v0.2.3";

  maelstrom-lib = stdenv.mkDerivation
    {
      inherit name version;

      src = fetchTarball {
        url = "https://github.com/jepsen-io/maelstrom/releases/download/${version}/${name}.tar.bz2";
        sha256 = "1hkczlbgps3sl4mh6hk49jimp6wmks8hki0bqijxsqfbf0hcakwq";
      };

      buildInputs = [ ];

      phases = "installPhase";
      installPhase = ''
        mkdir -p "$out/bin"
        cp -r $src/lib $out/lib
      '';

      meta = {
        homepage = "https://github.com/jepsen-io/maelstrom";
        description = "Workbench for writing toy implementations of distributed systems";
        license = lib.licenses.epl10;
        maintainers = [ ];
      };
    };
in
writers.writeDashBin name ''
  exec "${jre}/bin/java" -Djava.awt.headless=true -jar "${maelstrom-lib}/lib/maelstrom.jar" "$@"
''
