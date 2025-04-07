{
  description = "Mac nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, nix-homebrew, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.neovim
	  pkgs.obsidian
	  pkgs.mkalias
	  pkgs.wezterm
	  pkgs.devbox
	  pkgs.kanata
	  pkgs.localsend
	  pkgs.spectre-cli
	  pkgs.stow
	  pkgs.lua
	  pkgs.direnv
	  pkgs.fzf
	  pkgs.zellij
	  pkgs.dust
	  pkgs.fd
	  pkgs.sd
	  pkgs.starship
	  pkgs.bat
	  pkgs.eza
	  pkgs.ripgrep
        ];

      homebrew = {
        enable = true;
	brews = [
	  "mas"
	];
	casks = [
	  "breaktimer"
	  "flycut"
	  "nextcloud"
	];
	onActivation.cleanup = "zap";
	onActivation.autoUpdate = true;
	onActivation.upgrade = true;
      };

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
	  name = "system-applications";
	  paths = config.environment.systemPackages;
	  pathsToLink = "/Applications";
	};
	in
	  pkgs.lib.mkForce ''
	  # Set up applications
	  echo "setting up /Appplications..." >&2
	  rm -rf /Applications/Nix\ Apps
	  mkdir -p /Applications/Nix\ Apps
	  find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
	  while read -r src; do
	    app_name=$(basename "$src")
	    echo "copying $src" >&2
	    ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
	  done
	    '';

      fonts.packages = [
        pkgs.nerd-fonts.fira-code
      ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      nix.settings.trusted-users = [ "root" "@admin" "juergen.czerny"];

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."PC0571" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
	nix-homebrew.darwinModules.nix-homebrew
	{
	  nix-homebrew = {
	    enable = true;
	    enableRosetta = true;
	    user = "juergen.czerny";
	  };
	}
      ];
    };
  };
}
