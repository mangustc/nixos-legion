{ config, lib, pkgs, ... }:

let
	cfg = config.modules.plasma;
in {
	options.modules.plasma = {
		enable = lib.mkEnableOption "Enable plasma";
	};

	config = lib.mkIf cfg.enable {
		services.desktopManager.plasma6.enable = true;
		programs.dconf.enable = true;

		# plasma should only configure the desktop environment
		services.power-profiles-daemon.enable = lib.mkOverride 999 false;
		networking.networkmanager.enable = lib.mkOverride 999 false;
		hardware.bluetooth.enable = lib.mkOverride 999 false;

		environment.systemPackages = with pkgs; [
			maliit-keyboard
		];
		fonts.packages = with pkgs; [
		];
	};
}
