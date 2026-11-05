# Forced Fading Nametags

Server plugin and BeamMP client companion that enables BeamMP's native distance fade for player nametags using server-supplied settings.

## What it does

The server sends the active configuration to each player after they finish loading, and broadcasts changes to connected players. The client companion makes BeamMP's own nametag renderer use the server's fade enabled, fade direction, maximum distance, and full-hide settings. It uses BeamMP's synchronized vehicle positions locally, so player positions are not sent separately.

BeamMP's current nametag renderer exposes a single linear fade distance. It does not expose opacity controls or a configurable full-opacity plateau / second fade breakpoint. As a result, the default 20 m full-opacity and 30 m fade-start values are retained in the configuration as desired policy values but cannot be applied by the native renderer. In practice, native nametags fade linearly from full opacity at 0 m to zero at the configured maximum visibility distance (100 m by default). The game renders this continuously; the configurable update frequency is retained for future renderer support and is not used by BeamMP's per-frame renderer.

The client companion is required. BeamMP server Lua cannot directly alter a player's UI. Packaging the client zip in `Resources/Client` makes it part of the server's mod set and distributes it during connection. This ensures consistent behavior for ordinary clients that load server mods, but no BeamMP Lua mod can prevent a user who modifies their local game/mod files from bypassing its own UI behavior.

## Project layout

```text
ForcedFadingNametags/
├── LICENSE
├── README.md
├── Resources/
│   ├── Client/
│   │   └── ForcedFadingNametags.zip
│   └── Server/
│       └── ForcedFadingNametags/
│           ├── config.json
│           └── main.lua
└── docs/
    ├── configuration.md
    ├── installation.md
    └── testing.md
```

## Quick install

Copy `Resources/Client/ForcedFadingNametags.zip` and the `Resources/Server/ForcedFadingNametags` directory into the matching `Resources` folders of a BeamMP server running BeamMP-Server 3.x. Start or restart the server. See [installation](docs/installation.md).

## Configuration

Edit `Resources/Server/ForcedFadingNametags/config.json`. The server plugin validates and clamps values, then applies the configuration to new joins and broadcasts it when the config file is reloaded. Configuration fields and native renderer limitations are listed in [configuration](docs/configuration.md).

## Testing

Use the multiplayer scenarios in [testing](docs/testing.md). This source package has not been exercised in a live BeamMP session; the plan distinguishes API-level expectations from checks that require two running game clients.

## Technical references

- [BeamMP server Lua reference](https://docs.beammp.com/scripting/server/latest-server-reference/)
- [BeamMP server mod installation structure](https://docs.beammp.com/guides/mod-creation/server/getting-started/)
- [BeamMP client scripting reference](https://docs.beammp.com/scripting/mod-reference/)
- [BeamMP client API, including vehicle and nametag functions](https://docs.beammp.com/API%20documentation/Client-Side/)
- [BeamMP multiplayer nametag settings](https://docs.beammp.com/game/multiplayer-settings/)
- [BeamMP MPVehicleGE renderer source](https://github.com/BeamMP/BeamMP/blob/development/lua/ge/extensions/MPVehicleGE.lua)

