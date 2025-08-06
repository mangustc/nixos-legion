# Legion Go NixOS configuration

Legion go nixos configuration you can use for reference to build your own config.

`Steam Session` is the name of gamescope integrated session launched with steam integration and Steam Deck command line arguments.

## Quirks and Fixes

1. To get Steam Session working you should first launch steam using Plasma. After all steam files are downloaded you can use Steam Session as normal.
2. Unlike SteamOS, it does not boot directly into gamescope steam session. Instead, it launches SDDM where you can choose to either launch Plasma or Steam Session. SDDM was chosen since it supports touchscreen.

## Known problems

1. Handheld daemon has to be updated manually using overlays or similar. This is due to `adjustor` package not being packaged in nixpkgs (as on 25.05).
