{ pkgs, lib, ... }:
final: prev: {
	adjustor = (import ./adjustor.nix { inherit final prev lib; });
	steam-stubs = (import ./steam-stubs { inherit final prev lib; });
	handheld-daemon = (import ./handheld-daemon.nix { inherit final prev lib; });
	steam = (import ./steam.nix { inherit final prev lib; });
}
