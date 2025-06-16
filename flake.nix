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
    zephyrDepsHash = "sha256-ukLu0r9FBg5ixrsxpaMikPjDWeBgTQGl/adChUWvgVg=";
    src = nixpkgs.lib.sourceFilesBySuffices self [".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig" "yaml"];
    meta = {
      description = "ZMK firmware";
      license = nixpkgs.lib.licenses.mit;
      platforms = nixpkgs.lib.platforms.all;
    };
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in rec {
      default = korne;
      korne = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        inherit src zephyrDepsHash meta;
        name = "korne";
        board = "nice_nano_v2";
        parts = ["dongle" "left" "right"];
        shield = "korne_%PART% nice_view_adapter nice_view";
        extraCmakeFlags = [
          "-DCMAKE_C_FLAGS=-Wno-int-conversion"
        ];
      };

      corne = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        inherit src zephyrDepsHash meta;
        name = "corne";
        board = "nice_nano_v2";
        parts = ["dongle" "left" "right"];
        shield = "corne_%PART% nice_view_adapter nice_view";
        extraCmakeFlags = [
          "-DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n"
          "-DCMAKE_C_FLAGS=-Wno-int-conversion"
        ];
      };
      corne-just-dongle = zmk-nix.legacyPackages.${system}.buildKeyboard {
        inherit src zephyrDepsHash meta;
        name = "corne";
        board = "nice_nano_v2";
        shield = "corne_dongle";
        extraCmakeFlags = ["-DCMAKE_C_FLAGS=-Wno-int-conversion"];
      };
      # corne-with-dongle = pkgs.symlinkJoin {
      #   name = "corne-with-dongle";
      #   paths = [corne corne-just-dongle];
      # };
      corne-with-dongle = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        inherit src zephyrDepsHash meta;
        name = "corne";
        board = "nice_nano_v2";
        parts = ["dongle" "left" "right"];
        shield = "corne_%PART% nice_view_adapter nice_epaper";
        extraCmakeFlags = ["-DCMAKE_C_FLAGS=-Wno-int-conversion"];
      };
      reset = zmk-nix.legacyPackages.${system}.buildKeyboard {
        inherit src zephyrDepsHash meta;
        name = "reset";
        board = "nice_nano_v2";
        shield = "settings_reset";
      };
      flash = zmk-nix.packages.${system}.flash.override {firmware = corne;};
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
