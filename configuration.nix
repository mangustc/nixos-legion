{ config, lib, pkgs, ... }:
let
	hostname = "legion";
	username = "legion";
in
{
	nix = {
		settings = {
			experimental-features = ["nix-command" "flakes"];
			auto-optimise-store = true;
		};
	};
	nixpkgs.config.allowUnfree = true;
	nixpkgs.overlays = [
		(import ./overlays { inherit pkgs lib; })
	];

	imports = [
		./hardware-configuration.nix
		./modules
	];

	# SYSTEM SETTINGS
	boot = {
		loader.systemd-boot.enable = true;
		loader.efi.canTouchEfiVariables = true;
		kernelPackages = pkgs.linuxPackages_latest;
		blacklistedKernelModules = [
			"pcspkr"
			"iTCO_wdt"
			"sp5100_tco"
		];
		kernelParams = [
			"nowatchdog"
			"fbcon=vc:2-6"
			"amdgpu.sg_display=0"
		];
		initrd.kernelModules = [
			"amdgpu"
		];

		# Required to HHD to work on latest linux kernel package
		extraModulePackages = [
			config.boot.kernelPackages.acpi_call
		];
		kernelModules = [
			"acpi_call"
		];

		kernel.sysctl = {
			"net.ipv4.tcp_mtu_probing" = true;
			"net.ipv4.tcp_fin_timeout" = 5;
			"kernel.split_lock_mitigate" = 0;
			"kernel.nmi_watchdog" = 0;
			"kernel.soft_watchdog" = 0;
			"kernel.watchdog" = 0;
			"kernel.sched_cfs_bandwidth_slice_u" = 3000;
			"kernel.sched_latency_ns" = 3000000;
			"kernel.sched_min_granularity_ns" = 300000;
			"kernel.sched_wakeup_granularity_ns" = 500000;
			"kernel.sched_migration_cost_ns" = 50000;
			"kernel.sched_nr_migrate" = 128;
			"vm.max_map_count" = 2147483642;
		};
	};
	time.timeZone = "Asia/Astana";
	i18n.defaultLocale = "en_US.UTF-8";
	console.keyMap = "us";
	hardware.graphics = {
		enable = true;
		enable32Bit = true;
	};
	zramSwap = {
		enable = true;
		algorithm = "zstd";
		memoryPercent = 50;
		priority = 100;
	};
	networking = {
		networkmanager.enable = true;
		hostName = "nixos";
	};
	hardware.bluetooth.enable = true;
	services.pipewire = {
		enable = true;
		pulse.enable = true;
		extraConfig.pipewire = {
			"crackling-fix" = {
				"context.properties" = {
					"default.clock.rate" = 48000;
					"default.clock.min-quantum" = 512;
					"default.clock.quantum" = 1024;
					"default.clock.max-quantum" = 2048;
					"default.clock.quantum-limit" = 2048;
				};
			};
		};
		extraConfig.pipewire-pulse = {
			"crackling-fix" = {
				"pulse.properties" = {
					"pulse.min.req" = "1024/48000";
					"pulse.min.frag" = "1024/48000";
					"pulse.min.quantum" = "1024/48000";
					"pulse.default.req" = "2048/48000";
				};
			};
		};
		extraConfig.jack = {
			"crackling-fix" = {
				"jack.properties" = {
					"node.latency" = "1024/48000";
					"node.quantum" = "1024/48000";
				};
			};
		};
	};

	# DESKTOP MANAGERS
	modules.plasma.enable = true;
	services.displayManager.sddm = {
		enable = true;
		wayland.enable = true;
	};
	services.xserver = {
		enable = true;
		videoDrivers = [ "amdgpu" ];
		displayManager.lightdm.enable = lib.mkForce false;
	};

	# PROGRAMS
	modules.fish.enable = true;
	programs.firefox.enable = true;
	programs.git.enable = true;
	modules.flatpak = {
		enable = true;
		desiredFlatpaks = [
			"com.discordapp.Discord"
		];
	};

	# HANDHELD USE SETTINGS
	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true;
		localNetworkGameTransfers.openFirewall = true;
	};
	services.handheld-daemon = {
		enable = true;
		user = "${username}";
		ui.enable = true;
	};
	# any power profile daemons conflict with handheld-daemon
	services.power-profiles-daemon.enable = false;
	modules.steamSession.enable = true;
	programs.fuse.userAllowOther = true;
	# allow user to login in sddm without a password so you can enter with only touchpad
	security.pam.services.sddm = {
		text = lib.mkForce ''
auth      sufficient    pam_succeed_if.so user = ${username}
auth      substack      login
account   include       login
password  substack      login
session   include       login
		'';
	};
	# Enable brightness change as user
	services.udev.extraRules = ''
SUBSYSTEM=="backlight", ACTION=="add", \
	RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness", \
	RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
	'';

	users.defaultUserShell = pkgs.bash;
	users.users.${username} = {
		isNormalUser = true;
		extraGroups = [
			"wheel"
			"audio"
			"video"
			"input"
			"tty"
			"networkmanager"
		];
		useDefaultShell = true;
	};

	environment.variables = let
		xdg-cache-home = "$HOME/.cache";
		xdg-config-home = "$HOME/.config";
		xdg-data-home = "$HOME/.local/share";
		xdg-state-home = "$HOME/.local/state";
	in {
		XDG_CACHE_HOME  = xdg-cache-home;
		XDG_CONFIG_HOME = xdg-config-home;
		XDG_DATA_HOME   = xdg-data-home;
		XDG_STATE_HOME  = xdg-state-home;
		PATH = [
			"$HOME/.local/bin"
		];
		HISTFILE = "${xdg-state-home}/bash/history";
	};
	environment.systemPackages = with pkgs; [
		eza
		pavucontrol
		mpv
		tealdeer
		unzip
		lazygit
		btop
		gcc
		wl-clipboard
		xclip
		adwaita-icon-theme
		python3

		# gaming
		protonplus
		mangohud
		wineWowPackages.stable
	];
	fonts.packages = with pkgs; [
		noto-fonts
		noto-fonts-emoji
		nerd-fonts.jetbrains-mono
	];

	system.stateVersion = "25.05"; # Did you read the comment?
}

