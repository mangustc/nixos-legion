{ config, lib, pkgs, ... }:

let
	cfg = config.modules.fish;
in {
	options.modules.fish = {
		enable = lib.mkEnableOption "Enable fish";
	};

	config = lib.mkIf cfg.enable {
		programs.bash = {
			interactiveShellInit = ''
if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]; then
	shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
	exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
fi
			'';
		};
		programs.fish = {
			enable = true;
			interactiveShellInit = ''
alias eza "eza -M --icons=always --no-permissions --group-directories-first --git --color=always"
abbr --position anywhere rm "rm -vrf";
abbr --position anywhere cp "cp -vr";
abbr --position anywhere mv "mv -vf";
abbr --position anywhere t "tldr";
abbr --position anywhere tree "tree -C";
abbr --position anywhere ls "eza --time-style relative -lA";
abbr --position anywhere lst "eza --time-style relative -lA -T";
abbr --position anywhere lss "eza --time-style relative -lA --total-size";
abbr --position anywhere lsst "eza --time-style relative -lA -T --total-size";
abbr --position anywhere lsts "eza --time-style relative -lA -T --total-size";
			'';
		};
		environment.systemPackages = with pkgs; [
		];
	};
}

