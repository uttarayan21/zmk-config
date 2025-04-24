{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    zmk-nix,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = corne;

      corne = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "corne";

        src = nixpkgs.lib.sourceFilesBySuffices self [".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig" "yaml"];

        board = "nice_nano_v2";
        shield = "corne_%PART% nice_view_adapter nice_view";

        zephyrDepsHash = "sha256-cnRLYv1MQN/j9KEW+vVgCQ7GhPNGr1fc9/akj8OPGQ0=";

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };
      korne = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "korne";

        src = nixpkgs.lib.sourceFilesBySuffices self [".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig" "yaml"];

        board = "nice_nano_v2";
        shield = "corne_%PART%";

        zephyrDepsHash = "sha256-cnRLYv1MQN/j9KEW+vVgCQ7GhPNGr1fc9/akj8OPGQ0=";

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.${system}.flash.override {firmware = corne;};
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
