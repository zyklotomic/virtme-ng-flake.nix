{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.virtme-ng =
      let pkgs = import nixpkgs {
            system = "x86_64-linux";
          };
          virtme-ng-init = pkgs.rustPlatform.buildRustPackage {
            pname = "virtme-ng-init";
            version = "0.0.0";
            src = pkgs.fetchgit {
              url = "https://github.com/arighi/virtme-ng-init.git";
              rev = "450872b50abb423c855f32994af32917a4f9db6a";
              hash = "sha256-2ddAagkk8aHMdP0qrBumDC7FAOFNo7cKSom1Uk/W0c8=";
            };

            cargoSha256 = "sha256-2ddAagkk8aHMdP0qrBumDC7FAOFNo7cKSom1Uk/W0c8=";

            # TODO: PR for Cargo.lock upstream, then we can remove this patch
            cargoLock.lockFileContents = builtins.readFile ./Cargo.lock;
            postPatch = ''
              ln -s ${./Cargo.lock} Cargo.lock
            '';
          };
          linux_gcc_deps = [
            pkgs.gcc
            pkgs.ncurses
            pkgs.flex
            pkgs.bison
            pkgs.bc
            pkgs.pkg-config
            pkgs.elfutils
            pkgs.openssl
          ];
      in pkgs.python311Packages.buildPythonApplication {
        pname = "virtme-ng";
        version = "1.22";
        src = pkgs.fetchgit {
          url = "https://github.com/arighi/virtme-ng.git";
          rev = "refs/tags/v1.22";
          hash = "sha256-DtViI0+cZEYgxz+M1WeJgp1DB5l4/dRn+h+HGe2p6Ms=";
        };

        configurePhase = "export BUILD_VIRTME_NG_INIT=0";
        setuptoolsCheckPhase = "echo SKIPPING setuptoolsCheckPhase";

        propagatedBuildInputs = [ pkgs.python3Packages.argcomplete ] ++ linux_gcc_deps;
        nativeBuildInputs = [ pkgs.python3Packages.argcomplete ];
        buildInputs = [ virtme-ng-init pkgs.qemu ];
        dependencies = [ pkgs.python3Packages.requests pkgs.python3Packages.setuptools ];
      };

      packages.x86_64-linux.default = self.packages.x86_64-linux.virtme-ng;
  };
}
