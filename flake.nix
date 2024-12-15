{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [
              # python312Packages.boto3 = prev.python312Packages.boto.overrideAttrs(old: rec {
                # version = "3.12.6";
              # });
          ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          pythonWithPackages = pkgs.python312.withPackages (p: with p; [ boto3 inquirer python-dateutil ]);
        in
        with pkgs;
        {
          apps = {
            # nix run .#prod
            prod = {
              type = "app";
              program = toString (pkgs.writeShellScript "prod-awssso" ''
              ${pythonWithPackages}/bin/python3 ./awssso --login crescent
              ${pythonWithPackages}/bin/python3 ./awssso crescent
              '');
            };
            # nix run .#dev
            dev = {
              type = "app";
              program = toString (pkgs.writeShellScript "dev-awssso" ''
              ${pythonWithPackages}/bin/python3 ./awssso --login crescent-dev
              ${pythonWithPackages}/bin/python3 ./awssso crescent-dev
              '');
            };
            # nix run .#staging
            staging = {
              type = "app";
              program = toString (pkgs.writeShellScript "staging-awssso" ''
              ${pythonWithPackages}/bin/python3 ./awssso --login crescent-staging
              ${pythonWithPackages}/bin/python3 ./awssso crescent-staging
              '');
            };
          };
          devShells.default = mkShell {
            buildInputs = [
              pythonWithPackages
            ];
          };
        }
      );
}
